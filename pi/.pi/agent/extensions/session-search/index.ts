/**
 * session_search: BM25 search over past pi sessions, backed by SQLite FTS5.
 * Every search first re-indexes the session files that changed.
 */

import { DatabaseSync } from "node:sqlite";
import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const AGENT_DIR = join(homedir(), ".pi", "agent");
const SESSIONS_DIR = join(AGENT_DIR, "sessions");
const DB_PATH = join(AGENT_DIR, "session-index.db");
const SCHEMA = 4; // bump when the tables or the indexed content change; the index is rebuilt
const MAX_TEXT = 4000; // shortcut: long messages are cut, so the index stays small

export interface Hit {
	rid: number; // FTS row id, used to merge result sets
	path: string;
	entryId: string;
	role: string;
	ts: string;
	snippet: string;
}

// Pure: the searchable chunks of one JSONL entry. Exported for the self-check.
export function extractChunks(entry: any): { role: string; text: string }[] {
	if (entry?.type !== "message") return [];
	const m = entry.message;
	if (m?.role === "user") {
		const text =
			typeof m.content === "string"
				? m.content
				: (Array.isArray(m.content) ? m.content : [])
						.filter((b: any) => b?.type === "text" && typeof b.text === "string")
						.map((b: any) => b.text)
						.join("\n");
		return text ? [{ role: "user", text }] : [];
	}
	if (m?.role === "toolResult") {
		const text = (Array.isArray(m.content) ? m.content : [])
			.filter((b: any) => b?.type === "text" && typeof b.text === "string")
			.map((b: any) => b.text)
			.join("\n");
		return text ? [{ role: "tool", text }] : [];
	}
	if (m?.role !== "assistant" || !Array.isArray(m.content)) return [];
	const out: { role: string; text: string }[] = [];
	for (const b of m.content) {
		if (b?.type === "text" && b.text) out.push({ role: "assistant", text: b.text });
		if (b?.type === "toolCall" && b.name === "bash" && b.arguments?.command) {
			out.push({ role: "bash", text: String(b.arguments.command) });
		}
	}
	return out;
}

// Turns free text into an FTS5 query: each word quoted, joined by AND or OR.
export function toMatchQuery(query: string, op: "AND" | "OR"): string {
	const terms = query.match(/[\p{L}\p{N}_]+/gu) ?? [];
	return terms.map((t) => `"${t}"`).join(` ${op} `);
}

export class SessionIndex {
	private db: DatabaseSync;
	private sessionsDir: string;

	constructor(sessionsDir: string, dbPath: string) {
		this.sessionsDir = sessionsDir;
		mkdirSync(dirname(dbPath), { recursive: true });
		this.db = new DatabaseSync(dbPath);
		this.db.exec("PRAGMA busy_timeout = 5000");
		try {
			this.db.exec("PRAGMA journal_mode = WAL"); // stored in the file, so only the first process needs it
		} catch {}
		this.tx(() => {
			if ((this.db.prepare("PRAGMA user_version").get() as { user_version: number }).user_version < SCHEMA) {
				this.db.exec("DROP TABLE IF EXISTS hits; DROP TABLE IF EXISTS files;");
				this.db.exec(`PRAGMA user_version = ${SCHEMA}`);
			}
			this.db.exec(`
				CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, size INTEGER, mtime REAL);
				CREATE VIRTUAL TABLE IF NOT EXISTS hits USING fts5(
					text, path UNINDEXED, entry_id UNINDEXED, role UNINDEXED, ts UNINDEXED,
					tokenize = 'porter unicode61'
				);
			`);
		});
	}

	close() {
		this.db.close();
	}

	// Brings the index up to date: re-indexes changed files, drops deleted ones.
	indexAll(): void {
		const present = listJsonl(this.sessionsDir);
		for (const rel of present) this.indexFile(rel);
		this.tx(() => {
			const known = this.db.prepare("SELECT path FROM files").all() as { path: string }[];
			for (const { path } of known) {
				if (present.includes(path)) continue;
				this.db.prepare("DELETE FROM hits WHERE path = ?").run(path);
				this.db.prepare("DELETE FROM files WHERE path = ?").run(path);
			}
		});
	}

	// Replaces one file's rows when its size or mtime changed. A half-written last line fails JSON.parse and is skipped; the next change reindexes it.
	private indexFile(rel: string): void {
		const abs = join(this.sessionsDir, rel);
		const st = statSync(abs, { throwIfNoEntry: false });
		if (!st) return; // deleted since listing
		let text: string;
		try {
			text = readFileSync(abs, "utf8");
		} catch (err) {
			if ((err as NodeJS.ErrnoException).code === "ENOENT") return;
			throw err;
		}
		this.tx(() => {
			const row = this.db.prepare("SELECT size, mtime FROM files WHERE path = ?").get(rel) as
				| { size: number; mtime: number }
				| undefined;
			if (row?.size === st.size && row.mtime === st.mtimeMs) return;
			this.db.prepare("DELETE FROM hits WHERE path = ?").run(rel);
			const insert = this.db.prepare("INSERT INTO hits(text, path, entry_id, role, ts) VALUES (?, ?, ?, ?, ?)");
			for (const line of text.split("\n")) {
				if (!line.trim()) continue;
				let entry: any;
				try {
					entry = JSON.parse(line);
				} catch {
					continue;
				}
				for (const c of extractChunks(entry)) {
					insert.run(c.text.slice(0, MAX_TEXT), rel, entry.id ?? "", c.role, entry.timestamp ?? "");
				}
			}
			this.db.prepare("INSERT OR REPLACE INTO files(path, size, mtime) VALUES (?, ?, ?)").run(rel, st.size, st.mtimeMs);
		});
	}

	// folders: session folder names to keep; empty keeps all.
	search(query: string, limit: number, withTools = false, folders: string[] = []): Hit[] {
		const strict = this.run(toMatchQuery(query, "AND"), limit, withTools, folders); // all words, best first
		const seen = new Set(strict.map((h) => h.rid));
		const loose = this.run(toMatchQuery(query, "OR"), limit, withTools, folders).filter((h) => !seen.has(h.rid));
		return [...strict, ...loose].slice(0, limit); // partial matches only fill the rest
	}

	private run(match: string, limit: number, withTools: boolean, folders: string[]): Hit[] {
		if (!match) return [];
		const where = ["hits MATCH ?"];
		const args: (string | number)[] = [match];
		if (!withTools) where.push("role <> 'tool'");
		if (folders.length) {
			// stored paths are "<folder>/<file>.jsonl"; matching "<folder>/" keeps a folder exact
			where.push(`(${folders.map(() => "substr(path, 1, ?) = ?").join(" OR ")})`);
			for (const f of folders) args.push(f.length + 1, f + "/");
		}
		return this.db
			.prepare(
				`SELECT rowid AS rid, path, entry_id AS entryId, role, ts, snippet(hits, 0, '[', ']', '…', 16) AS snippet
				 FROM hits WHERE ${where.join(" AND ")} ORDER BY bm25(hits) LIMIT ?`,
			)
			.all(...args, limit) as unknown as Hit[];
	}

	private tx(fn: () => void): void {
		this.db.exec("BEGIN IMMEDIATE");
		try {
			fn();
			this.db.exec("COMMIT");
		} catch (err) {
			this.db.exec("ROLLBACK");
			throw err;
		}
	}
}

// Paths relative to dir, for every .jsonl file under it.
function listJsonl(dir: string): string[] {
	try {
		return (readdirSync(dir, { recursive: true }) as string[]).filter((e) => e.endsWith(".jsonl")).sort();
	} catch {
		return []; // no sessions yet
	}
}

// Session folder names for a repo: its main checkout and every worktree, as git lists them.
// pi names a session folder after the working directory: "/" becomes "-", wrapped in "--".
function sessionFolders(dir: string): string[] {
	let paths: string[];
	try {
		const out = execFileSync("git", ["-C", dir, "worktree", "list", "--porcelain"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });
		paths = out.split("\n").filter((l) => l.startsWith("worktree ")).map((l) => l.slice("worktree ".length));
	} catch {
		paths = [dir]; // not a git repo: just this directory
	}
	return paths.map((p) => "--" + p.replace(/^\//, "").replaceAll("/", "-") + "--");
}

export default function (pi: ExtensionAPI) {
	let index: SessionIndex | undefined;

	pi.registerTool({
		name: "session_search",
		label: "Session search",
		description:
			"Search past pi sessions (user messages, assistant replies, bash commands) with BM25 ranking. Returns matching snippets with the session file and entry id. Use it when the user refers to earlier work.",
		parameters: Type.Object({
			query: Type.String({ description: "Keywords to search for" }),
			limit: Type.Optional(Type.Number({ description: "Max results, 1-50, default 8" })),
			folder: Type.Optional(
				Type.String({
					description:
						"Only sessions started in this directory or its worktrees. Repo to search, with its main checkout and worktrees as git lists them. Default: the current directory's repo. e.g. /Users/reegnz/repos/github.infra.cloudera.com/taikun/taikun-api",
				}),
			),
			global: Type.Optional(Type.Boolean({ description: "Search all sessions, ignoring folder. Default false" })),
			includeToolOutput: Type.Optional(Type.Boolean({ description: "Also search tool output (large, noisy). Default false" })),
		}),
		async execute(_id, params, _signal, _onUpdate, ctx) {
			index ??= new SessionIndex(SESSIONS_DIR, DB_PATH);
			index.indexAll(); // pick up the current session's latest messages
			const limit = Math.min(Math.max(Math.floor(params.limit ?? 8), 1), 50);
			const hits = index.search(params.query, limit, params.includeToolOutput ?? false, params.global ? [] : sessionFolders(params.folder ?? ctx.cwd));
			const text = hits.length
				? hits
						.map((h) => `- ${h.ts} · ${h.role} · ${join(SESSIONS_DIR, h.path)}#${h.entryId}\n  ${h.snippet}`)
						.join("\n")
				: "No matching sessions.";
			return { content: [{ type: "text", text }], details: undefined };
		},
	});

	pi.on("session_shutdown", () => {
		index?.close(); // also fires on reload and session replacement
		index = undefined;
	});
}
