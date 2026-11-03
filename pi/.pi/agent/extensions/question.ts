/**
 * Question Tool — Claude Code style: arrow keys navigate, type inline, Enter submits.
 * "Chat about this" is always appended as the last option.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey, Text, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const QuestionParams = Type.Object({
  question: Type.String({ description: "The question to ask the user" }),
  options: Type.Array(
    Type.Object({
      label: Type.String({ description: "Display label for the option" }),
      description: Type.Optional(
        Type.String({ description: "Optional description shown below label" }),
      ),
    }),
    { description: "Options for the user to choose from" },
  ),
});

export default function question(pi: ExtensionAPI) {
  pi.registerTool({
    name: "question",
    label: "Question",
    description:
      "Ask the user a question and let them pick from options. Use when you need user input to proceed.",
    promptSnippet: "Ask the user a clarifying question with selectable options",
    promptGuidelines: [
      "Use the question tool liberally — whenever there is ambiguity, a meaningful choice to make, or multiple reasonable approaches, ask the user rather than guessing.",
      "Prefer the question tool over making assumptions. It is always better to ask than to proceed with the wrong approach.",
      "When using the question tool, provide clear, mutually exclusive options. Include a concise description for each option when it helps the user understand the difference.",
    ],
    parameters: QuestionParams,
    executionMode: "sequential",

    async execute(_id, params, _signal, _onUpdate, ctx) {
      if (ctx.mode !== "tui") {
        return {
          content: [{ type: "text", text: "Error: UI not available" }],
          details: { answer: null },
        };
      }
      if (!params.options.length) {
        return {
          content: [{ type: "text", text: "Error: No options provided" }],
          details: { answer: null },
        };
      }

      const options = [...params.options, { label: "Chat about this" }];

      const result = await ctx.ui.custom<{ label: string; note: string } | null>(
        (tui, theme, _kb, done) => {
          let idx = 0;
          let note = "";
          let cache: string[] | undefined;

          function refresh() {
            cache = undefined;
            tui.requestRender();
          }

          function handleInput(data: string) {
            if (matchesKey(data, Key.up)) {
              idx = Math.max(0, idx - 1);
              refresh();
              return;
            }
            if (matchesKey(data, Key.down)) {
              idx = Math.min(options.length - 1, idx + 1);
              refresh();
              return;
            }
            if (matchesKey(data, Key.escape)) {
              done(null);
              return;
            }
            if (matchesKey(data, Key.enter)) {
              done({ label: options[idx].label, note: note.trim() });
              return;
            }
            if (data === "\x7f" || data === "\b" || matchesKey(data, Key.backspace)) {
              if (note.length) {
                note = note.slice(0, -1);
                refresh();
              }
              return;
            }
            // \P{Cc} matches any non-control character (Unicode category "control" excluded)
            const isPrintable = data.length === 1 && /\P{Cc}/u.test(data);
            if (isPrintable) {
              note += data;
              refresh();
            }
          }

          function render(width: number): string[] {
            if (cache) return cache;
            const renderWidth = Math.max(1, width);

            function wrapPrefixed(prefix: string, text: string): string[] {
              const prefixWidth = visibleWidth(prefix);
              return wrapTextWithAnsi(text, Math.max(1, renderWidth - prefixWidth)).map((line, i) =>
                (i === 0 ? prefix : " ".repeat(prefixWidth)) + line,
              );
            }

            const lines: string[] = [
              theme.fg("accent", "─".repeat(renderWidth)),
              ...wrapPrefixed(" ", theme.fg("text", params.question)),
              "",
            ];

            for (let i = 0; i < options.length; i++) {
              const opt = options[i];
              const selected = i === idx;
              const prefix = selected ? theme.fg("accent", "> ") : "  ";
              const label = theme.fg(selected ? "accent" : "text", `${i + 1}. ${opt.label}`);

              if (selected) {
                const inline = note
                  ? "  " + theme.fg("text", note) + theme.fg("accent", "█")
                  : "  " + theme.fg("accent", "█") + theme.fg("dim", "type to add context");
                lines.push(...wrapPrefixed(prefix, label + inline));
              } else {
                lines.push(...wrapPrefixed(prefix, label));
              }

              if (opt.description) {
                lines.push(...wrapPrefixed("     ", theme.fg("muted", opt.description)));
              }
            }

            lines.push(
              "",
              ...wrapPrefixed(
                " ",
                theme.fg("dim", "↑↓ navigate • type to add context • Enter to submit • Esc to cancel"),
              ),
              theme.fg("accent", "─".repeat(renderWidth)),
            );

            return (cache = lines);
          }

          return {
            render,
            invalidate: () => { cache = undefined; },
            handleInput,
          };
        },
      );

      if (!result) {
        return {
          content: [{ type: "text", text: "User cancelled" }],
          details: { answer: null },
        };
      }

      const parts = [`User selected: ${result.label}`];
      if (result.note) parts.push(`with note: ${result.note}`);

      return {
        content: [{ type: "text", text: parts.join(", ") }],
        details: { answer: result.label, note: result.note || null },
      };
    },

    renderCall(args, theme) {
      const opts = (Array.isArray(args.options) ? args.options : []) as { label: string }[];
      const numbered = [...opts, { label: "Chat about this" }].map(
        (o, i) => `  ${i + 1}. ${o.label}`,
      );
      return new Text(
        theme.fg("toolTitle", theme.bold("Question: ")) +
        theme.fg("muted", args.question) +
        "\n" +
        numbered.map((o) => theme.fg("dim", o)).join("\n"),
        0,
        0,
      );
    },

    renderResult(result, _opts, theme) {
      const d = result.details as { answer: string | null; note?: string | null } | undefined;
      if (!d?.answer) {
        return new Text(theme.fg("warning", "Cancelled"), 0, 0);
      }
      let text = theme.fg("success", "✓ ") + theme.fg("accent", d.answer);
      if (d.note) {
        text += "  " + theme.fg("muted", `"${d.note}"`);
      }
      return new Text(text, 0, 0);
    },
  });
}
