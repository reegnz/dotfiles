// Self-check: node --experimental-strip-types check.ts
import { mkdtempSync, mkdirSync, writeFileSync, appendFileSync, rmSync, unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { spawn } from "node:child_process";
import { registerHooks } from "node:module";
import assert from "node:assert/strict";
// index.ts imports typebox, which plain node cannot find. Map it to pi's copy first.
const TYPEBOX_URL = pathToFileURL("/opt/homebrew/opt/pi-coding-agent/libexec/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/typebox/build/index.mjs").href;
registerHooks({ resolve: (s, c, next) => (s === "typebox" ? { url: TYPEBOX_URL, shortCircuit: true } : next(s, c)) });
const { SessionIndex, extractChunks, toMatchQuery } = await import("./index.ts");

const root = mkdtempSync(join(tmpdir(), "ss-check-"));
const sessions = join(root, "sessions", "--proj--");
mkdirSync(sessions, { recursive: true });
const file = join(sessions, "2026-01-01_abc.jsonl");
const line = (o: object) => JSON.stringify(o) + "\n";
writeFileSync(file,
	line({ type: "session", id: "abc", cwd: "/proj" }) +
	line({ type: "message", id: "e1", timestamp: "2026-01-01T10:00:00Z", message: { role: "user", content: [{ type: "text", text: "how do I deploy the OpenBao oidc provider" }] } }) +
	line({ type: "message", id: "e2", timestamp: "2026-01-01T10:00:01Z", message: { role: "assistant", content: [
		{ type: "toolCall", name: "bash", arguments: { command: "kubectl apply -f oidc.yaml" } },
		{ type: "text", text: "Apply the oidc manifest first." }] } }) +
	line({ type: "message", id: "e3", timestamp: "x", message: { role: "toolResult", content: [{ type: "text", text: "kubectl listed pods" }] } }));

const dbPath = join(root, "index.db");
const idx = new SessionIndex(join(root, "sessions"), dbPath);

// 1. indexing: user text, assistant text and bash are kept; tool output is stored but hidden by default
idx.indexAll();
assert.equal(idx.search("oidc", 10).length, 3, "user + assistant text + bash command");
assert.equal(idx.search("listed pods", 10).length, 0, "tool output is excluded by default");
assert.equal(idx.search("listed pods", 10, true).length, 1, "tool output is searchable with includeToolOutput");
assert.equal(idx.search("listed pods", 10, true)[0].role, "tool");

// 2. append: only the new entry is added, the rest is not duplicated
appendFileSync(file, line({ type: "message", id: "e4", timestamp: "t", message: { role: "user", content: "rotate the openbao token" } }));
idx.indexAll();
assert.equal(idx.search("openbao", 10).length, 2, "old rows kept, new row added, no duplicates");

// 3. search: all-word matches first, partial matches fill the rest
const hits = idx.search("openbao token", 10);
assert.equal(hits[0].entryId, "e4", "entry matching both terms ranks first");
assert.match(hits[0].snippet, /\[openbao\]/i);
assert.equal(idx.search("openbao kubectl", 10).length, 3, "partial matches are returned: three entries");
assert.equal(idx.search("openbao kubectl", 10, true).length, 4, "with tool output, the fourth hit appears");

// 3b. folder filter: only sessions in the listed folders
assert.equal(idx.search("openbao", 10, false, ["--proj--"]).length, 2, "the listed folder is kept");
assert.equal(idx.search("openbao", 10, false, ["--other--"]).length, 0, "other folders are excluded");
assert.equal(idx.search("openbao", 10, false, ["--proj"]).length, 0, "folder match is exact, not a prefix");
assert.equal(idx.search("openbao", 10, false, ["--other--", "--proj--"]).length, 2, "several folders are allowed");

// 4. replaced file: old rows go, new rows come in
writeFileSync(file, line({ type: "session", id: "abc" }) + line({ type: "message", id: "n1", timestamp: "t", message: { role: "user", content: "fresh" } }));
idx.indexAll();
assert.equal(idx.search("oidc", 10).length, 0, "old rows gone after replacement");
assert.equal(idx.search("fresh", 10).length, 1);

// 5. deleted file: its rows go
unlinkSync(file);
idx.indexAll();
assert.equal(idx.search("fresh", 10).length, 0, "rows of a deleted file are dropped");

// 6. pure helpers
assert.equal(toMatchQuery('a "b"', "AND"), '"a" AND "b"');
assert.equal(toMatchQuery("!!!", "OR"), "");
assert.deepEqual(extractChunks({ type: "message", message: { role: "system" } }), []);
idx.close();

// 7. several processes share one database: 300 entries are indexed once each
const shared = join(root, "shared");
mkdirSync(join(shared, "p"), { recursive: true });
writeFileSync(join(shared, "p", "big.jsonl"), Array.from({ length: 300 }, (_, i) =>
	line({ type: "message", id: `s${i}`, timestamp: "t", message: { role: "user", content: `word${i} sharedterm` } })).join(""));
const sharedDb = join(root, "shared.db");
const worker = `require("node:module").registerHooks({ resolve: (s, c, next) => (s === \"typebox\" ? { url: ${JSON.stringify(TYPEBOX_URL)}, shortCircuit: true } : next(s, c)) });
(async () => {
	const { SessionIndex } = await import(${JSON.stringify(pathToFileURL(join(import.meta.dirname, "index.ts")).href)});
	const i = new SessionIndex(${JSON.stringify(shared)}, ${JSON.stringify(sharedDb)});
	i.indexAll();
	i.close();
})();`;
const runWorker = () => new Promise<void>((resolve, reject) => {
	const p = spawn(process.execPath, ["--experimental-strip-types", "-e", worker], { stdio: ["ignore", "ignore", "pipe"] });
	let err = "";
	p.stderr.on("data", (d) => (err += d));
	p.on("close", (code) => (code === 0 ? resolve() : reject(new Error(err))));
});
await Promise.all([runWorker(), runWorker(), runWorker()]);
const after = new SessionIndex(shared, sharedDb);
assert.equal(after.search("sharedterm", 1000).length, 300, "each entry indexed exactly once");
after.close();

rmSync(root, { recursive: true, force: true });
console.log("session-search checks passed");
