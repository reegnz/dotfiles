// ghostex-pi-session-extension-marker v5
import { spawnSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import type { AgentEndEvent, ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

function firstString(...values: unknown[]): string | null {
  for (const value of values) {
    if (typeof value === "string" && value.trim().length > 0) return value.trim();
  }
  return null;
}

function resolveExecutable(name: string): string {
  const pathEnv = process.env.PATH || "";
  for (const dir of pathEnv.split(path.delimiter)) {
    if (!dir) continue;
    const candidate = path.join(dir, name);
    try {
      fs.accessSync(candidate, fs.constants.X_OK);
      return candidate;
    } catch (_) {}
  }
  return name;
}

function looksLikePiExecutable(value: string): boolean {
  const base = path.basename(value).toLowerCase();
  return base === "pi" || base === "pi-coding-agent";
}

function looksLikePiScript(value: string): boolean {
  const normalized = value.replaceAll("\\", "/");
  const base = path.basename(normalized).toLowerCase();
  return (
    normalized.includes("/@earendil-works/pi-coding-agent/") ||
    normalized.includes("/@mariozechner/pi-coding-agent/") ||
    normalized.includes("/packages/coding-agent/") ||
    (base === "cli.js" && normalized.includes("pi-coding-agent")) ||
    (base === "cli.ts" && normalized.includes("coding-agent"))
  );
}

function normalizedLaunchArgv(): string[] {
  const raw = Array.isArray(process.argv) ? process.argv.map((value) => String(value)) : [];
  if (raw.length === 0) return [resolveExecutable("pi")];
  if (looksLikePiExecutable(raw[0])) return raw;
  if (raw.length > 1 && looksLikePiScript(raw[1])) {
    return [resolveExecutable("pi"), ...raw.slice(2)];
  }
  return [resolveExecutable("pi"), ...raw.slice(1)];
}

function base64NulSeparated(values: string[]): string {
  const bytes: Buffer[] = [];
  for (const value of values) {
    bytes.push(Buffer.from(String(value), "utf8"));
    bytes.push(Buffer.from([0]));
  }
  return Buffer.concat(bytes).toString("base64");
}

function hookEnvironment(cwd: string): NodeJS.ProcessEnv {
  const env: NodeJS.ProcessEnv = { ...process.env, GHOSTEX_AGENT: "pi" };
  delete env.AMP_API_KEY;
  for (const key of ["ANSI_COLORS_DISABLED", "NO_COLOR", "NODE_DISABLE_COLORS"]) delete env[key];
  if (!env.GHOSTEX_AGENT_LAUNCH_ARGV_B64) {
    const argv = normalizedLaunchArgv();
    env.GHOSTEX_AGENT_LAUNCH_KIND = "pi";
    env.GHOSTEX_AGENT_LAUNCH_EXECUTABLE = argv[0] || resolveExecutable("pi");
    env.GHOSTEX_AGENT_LAUNCH_ARGV_B64 = base64NulSeparated(argv);
    env.GHOSTEX_AGENT_LAUNCH_CWD = cwd || process.cwd();
  }
  return env;
}

function eventName(subcommand: string): string {
  switch (subcommand) {
    case "session-start":
      return "SessionStart";
    case "prompt-submit":
      return "UserPromptSubmit";
    case "stop":
      return "Stop";
    default:
      return subcommand;
  }
}

function textFromContent(content: unknown): string | null {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return null;
  const parts: string[] = [];
  for (const block of content) {
    if (!block || typeof block !== "object") continue;
    const typed = block as { type?: unknown; text?: unknown };
    if (typed.type === "text" && typeof typed.text === "string") parts.push(typed.text);
  }
  return parts.join("\n") || null;
}

function lastAssistantMessage(event: AgentEndEvent): string | undefined {
  for (let index = event.messages.length - 1; index >= 0; index -= 1) {
    const message = event.messages[index];
    if (!message || typeof message !== "object") continue;
    const typed = message as { role?: unknown; content?: unknown };
    if (typed.role !== "assistant") continue;
    const text = firstString(textFromContent(typed.content));
    if (text) return text;
  }
  return undefined;
}

const SUBAGENT_TOOL_NAMES = new Set(["subagent", "team_spawn", "superpowers_dispatch", "Task"]);

function toolNameFrom(event: unknown): string | null {
  if (!event || typeof event !== "object") return null;
  const typed = event as { toolName?: unknown; tool_name?: unknown; name?: unknown };
  return firstString(typed.toolName, typed.tool_name, typed.name);
}

function isSubagentTool(toolName: string | null): boolean {
  if (!toolName) return false;
  return SUBAGENT_TOOL_NAMES.has(toolName) || /subagent/i.test(toolName);
}

function toolIsError(event: unknown): boolean | undefined {
  if (!event || typeof event !== "object") return undefined;
  const typed = event as { isError?: unknown; is_error?: unknown; error?: unknown };
  if (typeof typed.isError === "boolean") return typed.isError;
  if (typeof typed.is_error === "boolean") return typed.is_error;
  if (typed.error !== undefined && typed.error !== null) return true;
  return undefined;
}

type OptionalEventHandler = (event: unknown, ctx: ExtensionContext) => void | Promise<void>;

function registerOptional(api: ExtensionAPI, name: string, handler: OptionalEventHandler): void {
  try {
    (api.on as unknown as (event: string, handler: OptionalEventHandler) => void)(name, handler);
  } catch (_) {}
}

type TurnEnd = { event: string; extra: Record<string, unknown> };

// Esc ends a run as `aborted` and a provider failure as `error`; neither is a finished turn.
function turnEndFor(event: AgentEndEvent): TurnEnd {
  let stopReason: unknown;
  for (let index = event.messages.length - 1; index >= 0; index -= 1) {
    const message = event.messages[index] as { role?: unknown; stopReason?: unknown } | undefined;
    if (message && message.role === "assistant") {
      stopReason = message.stopReason;
      break;
    }
  }
  const name = stopReason === "aborted" ? "Interrupt" : stopReason === "error" ? "StopFailure" : "Stop";
  return { event: name, extra: { last_assistant_message: lastAssistantMessage(event) } };
}

function isIdle(ctx: ExtensionContext): boolean {
  try {
    const typed = ctx as unknown as { isIdle?: () => boolean };
    return typeof typed.isIdle === "function" ? typed.isIdle() : false;
  } catch (_) {
    return false;
  }
}

function sendHook(subcommand: string, ctx: ExtensionContext, extra: Record<string, unknown> = {}): void {
  if (process.env.GHOSTEX_PI_HOOKS_DISABLED === "1") return;

  const sessionId = firstString(ctx.sessionManager.getSessionId());
  if (!sessionId) return;

  const cwd = firstString(ctx.cwd, process.cwd()) || process.cwd();
  const event = eventName(subcommand);
  const payload: Record<string, unknown> = {
    agent: "pi",
    session_id: sessionId,
    cwd,
    hook_event_name: event,
    event,
    transcript_path: ctx.sessionManager.getSessionFile() || undefined,
    ...extra,
  };
  // Windows cannot run the notify hook script itself; gxserver runs it for the agent there.
  const [command, args] =
    process.platform === "win32"
      ? ["", ["agent-hook-notify-native", "/Users/reegnz/.local/share/ghostex/hooks/agent-shell-notify.sh", "pi"]]
      : ["/Users/reegnz/.local/share/ghostex/hooks/agent-shell-notify.sh", []];
  try {
    spawnSync(command, args, {
      input: JSON.stringify(payload),
      encoding: "utf8",
      env: hookEnvironment(cwd),
      stdio: ["pipe", "ignore", "ignore"],
      timeout: 5000,
      windowsHide: true,
    });
  } catch (_) {}
}

export default function ghostexPiSessionExtension(pi: ExtensionAPI) {
  // `agent_end` can be followed by an automatic retry or queued follow-ups; Pi 1.0 marks the real
  // end of the work with `agent_settled`. Older Pi never fires it, so the turn ends on `agent_end`
  // until the first `agent_settled` proves the event exists, then waits for it.
  let settledSeen = false;
  let pendingTurnEnd: TurnEnd | null = null;
  let promptOpen = false;

  pi.on("session_start", async (_event, ctx) => {
    sendHook("session-start", ctx);
  });

  pi.on("before_agent_start", async (event, ctx) => {
    sendHook("prompt-submit", ctx, { prompt: event.prompt });
  });

  registerOptional(pi, "agent_start", () => {
    pendingTurnEnd = null;
  });

  pi.on("agent_end", async (event, ctx) => {
    const turnEnd = turnEndFor(event);
    if (settledSeen) {
      pendingTurnEnd = turnEnd;
      return;
    }
    sendHook(turnEnd.event, ctx, turnEnd.extra);
  });

  registerOptional(pi, "agent_settled", (_event, ctx) => {
    const firstSettle = !settledSeen;
    settledSeen = true;
    const turnEnd = pendingTurnEnd;
    pendingTurnEnd = null;
    if (turnEnd && !firstSettle) sendHook(turnEnd.event, ctx, turnEnd.extra);
  });

  // A dialog an extension opens mid-run (a question, a confirmation) blocks Pi on the user.
  registerOptional(pi, "ui_prompt_start", (event, ctx) => {
    if (isIdle(ctx)) return;
    promptOpen = true;
    const typed = event as { title?: unknown; kind?: unknown };
    sendHook("Notification", ctx, {
      message: firstString(typed.title) ?? "Pi is waiting for your answer",
      notification_type: firstString(typed.kind) ?? undefined,
    });
  });

  registerOptional(pi, "ui_prompt_end", (_event, ctx) => {
    if (!promptOpen) return;
    promptOpen = false;
    sendHook(isIdle(ctx) ? "SessionIdle" : "PostToolUse", ctx);
  });

  registerOptional(pi, "tool_execution_start", (event, ctx) => {
    const toolName = toolNameFrom(event);
    sendHook(isSubagentTool(toolName) ? "SubagentStart" : "PreToolUse", ctx, {
      tool_name: toolName ?? undefined,
    });
  });

  registerOptional(pi, "tool_execution_end", (event, ctx) => {
    const toolName = toolNameFrom(event);
    sendHook(isSubagentTool(toolName) ? "SubagentStop" : "PostToolUse", ctx, {
      tool_name: toolName ?? undefined,
      is_error: toolIsError(event),
    });
  });

  registerOptional(pi, "session_before_compact", (_event, ctx) => {
    sendHook("PreCompact", ctx);
  });

  registerOptional(pi, "session_compact", (_event, ctx) => {
    sendHook("PostCompact", ctx);
  });
}
