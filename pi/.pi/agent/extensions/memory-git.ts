import type { ExtensionAPI, ToolResultEvent } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { mkdir } from "node:fs/promises";
import { promisify } from "node:util";
import path from "node:path";

const execFileAsync = promisify(execFile);
const memoryDir = path.join(process.env.HOME ?? process.cwd(), ".agents", "memory");

function isMemoryPath(input: Record<string, unknown>): boolean {
  const candidate = typeof input.path === "string" ? input.path : undefined;
  if (!candidate) return false;
  const resolved = path.resolve(candidate);
  return resolved === memoryDir || resolved.startsWith(`${memoryDir}${path.sep}`);
}

async function git(...args: string[]): Promise<string> {
  const result = await execFileAsync("git", ["-C", memoryDir, ...args], {
    encoding: "utf8",
  });
  return result.stdout.trim();
}

export default function memoryGit(pi: ExtensionAPI) {
  let queue = Promise.resolve();
  let initialized = false;

  const persist = async () => {
    await mkdir(memoryDir, { recursive: true });
    if (!initialized) {
      await git("init", "--quiet");
      initialized = true;
    }

    await git("add", "--all");
    const staged = await git("diff", "--cached", "--quiet").then(
      () => false,
      () => true,
    );
    if (!staged) return;

    await git("commit", "-m", "memory: update");
  };

  const enqueue = (ctx: { ui: { notify(message: string, type?: "info" | "warning" | "error"): void } }) => {
    queue = queue.then(persist).catch((error: unknown) => {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`Memory Git persistence failed: ${message}`, "error");
    });
  };

  pi.on("tool_result", async (event: ToolResultEvent, ctx) => {
    // bash can write memory files (redirects, sed -i, cp...) and may exit non-zero after writing, so it skips the isError check.
    if (event.toolName === "bash") return enqueue(ctx);
    if (event.isError) return;
    if (event.toolName !== "write" && event.toolName !== "edit") return;
    if (!isMemoryPath(event.input)) return;
    enqueue(ctx);
  });

  pi.on("session_shutdown", async () => {
    await queue;
  });

  pi.registerCommand("memory-commit", {
    description: "Commit pending changes in ~/.agents/memory",
    handler: async (_args, ctx) => {
      enqueue(ctx);
      await queue;
      ctx.ui.notify("Agent memory persisted to Git.", "info");
    },
  });
}
