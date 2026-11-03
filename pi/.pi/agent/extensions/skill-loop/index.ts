/**
 * skill-loop: after a substantial agent run, a cheap model reviews the transcript and
 * creates or updates a skill in ~/.pi/agent/skill-library/. That directory is outside
 * pi's skill scan paths, so skills do not enter the system prompt. The agent reaches them
 * through the skill_search tool instead.
 *
 * Config (optional) ~/.pi/agent/skill-loop.json:
 *   { "model": "provider/model-id", "minToolCalls": 5, "maxTranscriptChars": 60000 }
 * Without "model" the session's current model is used.
 */

import { existsSync, mkdirSync, readFileSync, readdirSync, renameSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { uuidv7 } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const AGENT_DIR = join(homedir(), ".pi", "agent");
const CONFIG_PATH = join(AGENT_DIR, "skill-loop.json");
const LIB_ROOT = join(AGENT_DIR, "skill-library");
const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

interface Config {
	model?: string;
	minToolCalls: number;
	maxTranscriptChars: number;
}

interface Decision {
	action: "none" | "create" | "update";
	name?: string;
	description?: string;
	body?: string;
}

interface LibSkill {
	name: string;
	description: string;
	path: string;
	text: string;
}

function loadConfig(): Config {
	let user: Partial<Config> = {};
	if (existsSync(CONFIG_PATH)) user = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
	return { minToolCalls: 5, maxTranscriptChars: 60000, ...user };
}

function listLibrary(): LibSkill[] {
	if (!existsSync(LIB_ROOT)) return [];
	const out: LibSkill[] = [];
	for (const dir of readdirSync(LIB_ROOT, { withFileTypes: true })) {
		const path = join(LIB_ROOT, dir.name, "SKILL.md");
		if (!dir.isDirectory() || !existsSync(path)) continue;
		const text = readFileSync(path, "utf8");
		const description = text.match(/^description:\s*(.+)$/m)?.[1]?.replace(/^"|"$/g, "") ?? "";
		out.push({ name: dir.name, description, path, text });
	}
	return out;
}

// shortcut: keyword scoring over name, description and body, no embeddings or index, upgrade when the library passes ~200 skills
export function searchLibrary(skills: LibSkill[], query: string, limit = 3): LibSkill[] {
	const terms = query.toLowerCase().split(/[^a-z0-9]+/).filter(Boolean);
	if (terms.length === 0) return skills.slice(0, limit);
	return skills
		.map((s) => {
			const hay = s.text.toLowerCase();
			return { s, score: terms.filter((t) => hay.includes(t)).length };
		})
		.filter((x) => x.score > 0)
		.sort((a, b) => b.score - a.score)
		.slice(0, limit)
		.map((x) => x.s);
}

// The reviewer sees the whole library in one prompt. shortcut: no index yet, fine until ~50 skills.
function buildPrompt(transcript: string, skills: LibSkill[]): string {
	const library = skills.map((s) => `### ${s.name}\n${s.text}`).join("\n\n") || "(none yet)";
	return `Existing skills:\n${library}\n\nSession transcript:\n<transcript>\n${transcript}\n</transcript>`;
}

const SYSTEM_PROMPT = `You maintain a library of reusable agent skills (SKILL.md files) based on coding sessions.
Decide whether the transcript shows a reusable, non-obvious procedure: commands that worked after trial and error,
project facts, gotchas, or a workflow the agent had to rediscover. Ordinary one-off edits do not count.
- If an existing skill already covers it, use "update" with the complete new body (keep everything still valid).
- Otherwise use "create" with a new short kebab-case name.
- Never include secrets, tokens, credentials, or session-specific data.
Respond with JSON only, no prose:
{"action":"none"} or {"action":"create"|"update","name":"kebab-case-name","description":"when to use it, one or two sentences","body":"markdown instructions, no frontmatter"}`;

// Pure: turns the model's reply into a validated decision or null.
export function parseDecision(raw: string): Decision | null {
	const start = raw.indexOf("{");
	const end = raw.lastIndexOf("}");
	if (start < 0 || end < start) return null;
	let d: Decision;
	try {
		d = JSON.parse(raw.slice(start, end + 1));
	} catch {
		return null;
	}
	if (d.action === "none") return d;
	if (d.action !== "create" && d.action !== "update") return null;
	if (!d.name || !NAME_RE.test(d.name) || d.name.length > 64) return null;
	if (!d.description || d.description.length > 1024 || !d.body?.trim()) return null;
	return d;
}

function writeSkill(d: Decision, existing: LibSkill[]): string {
	const dir = join(LIB_ROOT, d.name!);
	const path = join(dir, "SKILL.md");
	const old = existing.find((s) => s.name === d.name);
	mkdirSync(dir, { recursive: true });
	if (old) writeFileSync(join(dir, "SKILL.md.prev"), old.text); // one-step undo
	const description = d.description!.replace(/\s+/g, " ").trim();
	writeFileSync(
		path,
		`---\nname: ${d.name}\ndescription: ${JSON.stringify(description)}\nmetadata:\n  generated-by: skill-loop\n---\n\n${d.body!.trim()}\n`,
	);
	return path;
}

export default function (pi: ExtensionAPI) {
	let buffer: any[] = [];
	let running = false;

	pi.registerTool({
		name: "skill_search",
		label: "Skill search",
		description:
			"Search the personal skill library for stored procedures, project facts and gotchas. Call with a query before repeating multi-step work. Empty query lists the library.",
		parameters: Type.Object({ query: Type.Optional(Type.String({ description: "Keywords to match against skill names and descriptions" })) }),
		async execute(_id, params) {
			const query = params.query ?? "";
			const hits = searchLibrary(listLibrary(), query, query.trim() ? 3 : Infinity);
			const text = hits.length ? hits.map((s) => `- ${s.name}: ${s.description}\n  path: ${s.path}`).join("\n") : "No matching skills.";
			return { content: [{ type: "text", text }], details: undefined };
		},
	});

	pi.registerTool({
		name: "skill_manage",
		label: "Skill manage",
		description:
			"Create, update, or delete a skill in the personal library. Use after you work out a non-obvious, reusable procedure. Check skill_search first to avoid duplicates. Delete moves the skill to a trash folder.",
		parameters: Type.Object({
			action: Type.Union([Type.Literal("create"), Type.Literal("update"), Type.Literal("delete")]),
			name: Type.String({ description: "kebab-case skill name" }),
			description: Type.Optional(Type.String({ description: "When to use it, one or two sentences (create/update)" })),
			body: Type.Optional(Type.String({ description: "Full markdown instructions without frontmatter (create/update)" })),
		}),
		async execute(_id, params) {
			const fail = (text: string) => ({ content: [{ type: "text" as const, text }], details: undefined, isError: true });
			const existing = listLibrary();
			const old = existing.find((s) => s.name === params.name);
			if (!NAME_RE.test(params.name) || params.name.length > 64) return fail(`Invalid name: ${params.name}`);
			if (params.action === "delete") {
				if (!old) return fail(`No skill named ${params.name}`);
				const trash = join(LIB_ROOT, ".deleted");
				mkdirSync(trash, { recursive: true });
				renameSync(dirname(join(LIB_ROOT, params.name, "SKILL.md")), join(trash, `${params.name}-${Date.now()}`));
				return { content: [{ type: "text", text: `Deleted ${params.name}` }], details: undefined };
			}
			if (params.action === "create" && old) return fail(`${params.name} exists; use update`);
			if (params.action === "update" && !old) return fail(`No skill named ${params.name}; use create`);
			const d = parseDecision(JSON.stringify({ action: params.action, name: params.name, description: params.description, body: params.body }));
			if (!d || d.action === "none") return fail("description and body are required and must be valid");
			const path = writeSkill(d, existing);
			return { content: [{ type: "text", text: `${params.action}d ${params.name} (${path})` }], details: undefined };
		},
	});

	pi.on("agent_end", (event) => {
		buffer.push(...event.messages);
	});

	pi.on("agent_settled", (event, ctx) => {
		const messages = buffer;
		buffer = [];
		if (event.aborted || running) return;
		const cfg = loadConfig();
		const toolCalls = messages.filter((m) => m.role === "toolResult").length;
		if (toolCalls < cfg.minToolCalls) return;

		const model = cfg.model
			? ctx.modelRegistry.find(...(cfg.model.split(/\/(.*)/s).slice(0, 2) as [string, string]))
			: ctx.model;
		if (!model) {
			ctx.ui.notify(`skill-loop: model ${cfg.model} not found, skipping`, "warning");
			return;
		}

		running = true;
		void (async () => {
			try {
				const transcript = serializeConversation(convertToLlm(messages)).slice(-cfg.maxTranscriptChars);
				const existing = listLibrary();
				const response = await ctx.modelRegistry.complete(
					model,
					{
						systemPrompt: SYSTEM_PROMPT,
						messages: [
							{ role: "user", content: [{ type: "text", text: buildPrompt(transcript, existing) }], timestamp: Date.now() },
						],
					},
					{ maxTokens: 4096, cacheRetention: "none", sessionId: uuidv7() },
				);
				const raw = response.content
					.filter((c: any) => c.type === "text")
					.map((c: any) => c.text)
					.join("\n");
				const d = parseDecision(raw);
				if (!d || d.action === "none") return;
				const path = writeSkill(d, existing);
				ctx.ui.notify(`skill-loop: ${d.action}d ${d.name} (${path})`, "info");
			} catch (err) {
				ctx.ui.notify(`skill-loop failed: ${(err as Error).message}`, "warning");
			} finally {
				running = false;
			}
		})();
	});
}
