/**
 * file_question tool — ask a question about files using the local decision model.
 *
 * Keeps file content out of the main model's context: read the files, build a
 * classifier state, and let the model return a single choice with probabilities.
 *
 * Usage (model calls):
 *   file_question({ files: ["foo.ts"], question: "...", answers: { yes: "...", no: "..." } })
 *
 * Requires the llama.cpp router with the decision model below available (set DECISION_MODEL).
 * Configure the server URL with LLAMA_BASE_URL (default http://localhost:8080/v1).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs/promises";
import * as path from "node:path";

const DECISION_MODEL = "ggml-org/Kev-4B-GGUF:Q8_0";

// Conservative character budget for file content; check the model's ctx-size in models.ini before raising.
// shortcut: hard-coded context budget, revisit if model is swapped for larger context
const MAX_TOTAL_CHARS = 40_000;

const FileQuestionParams = Type.Object({
  files: Type.Array(Type.String(), {
    description: "Paths of the files to read. Relative paths are resolved from the working directory.",
    minItems: 1,
  }),
  question: Type.String({
    description:
      "Ask one bounded classification question that maps to exactly one answer label. " +
      "Do not ask for lists, exhaustive references, paths, line numbers, exact values, commands, or quotes.",
  }),
  answers: Type.Record(Type.String(), Type.String(), {
    description:
      "Possible answers as { label: description }. " +
      "Use mutually exclusive, collectively covering labels (e.g. 'yes', 'no', 'unclear'); " +
      "each description explains exactly when that label applies.",
  }),
});

const ChoiceQuestionSchema = Type.Object({
  type: Type.Literal("choice"),
  instructions: Type.String(),
  criteria: Type.Record(Type.String(), Type.String()),
});
const ScoreQuestionSchema = Type.Object({
  type: Type.Literal("score"),
  instructions: Type.String(),
  criteria: Type.Array(Type.String()),
});
const NoulQuestionSchema = Type.Object({
  type: Type.Literal("noul"),
  instructions: Type.String(),
});

const FileGlobQuestionParams = Type.Object({
  glob: Type.String({
    description: "Glob pattern for files to read, relative to the working directory; directories are excluded.",
  }),
  questions: Type.Record(Type.String(), Type.Union([
    ChoiceQuestionSchema,
    ScoreQuestionSchema,
    NoulQuestionSchema,
  ]), {
    description:
      "Classifier questions keyed by ID. A {{file}} placeholder in a question ID or instructions expands that " +
      "question once per matched file. Use the same question shapes as the classifier: choice with criteria, " +
      "score with criteria, or noul. Example: " +
      "{\"inside_{{file}}\": {\"type\": \"noul\", \"instructions\": \"Is {{file}} bad?\"}}. " +
      "A {{file}} in choice or score criteria expands those options per matched file.",
  }),
});

type GlobQuestion =
  | { type: "choice"; instructions: string; criteria: Record<string, string> }
  | { type: "score"; instructions: string; criteria: string[] }
  | { type: "noul"; instructions: string };

const FILE_TEMPLATE = /\{\{file\}\}/g;

function hasFileTemplate(value: string): boolean {
  return value.includes("{{file}}");
}

function renderFileTemplate(value: string, filePath: string): string {
  return value.replace(FILE_TEMPLATE, filePath);
}

function renderChoiceCriteria(
  criteria: Record<string, string>,
  files: string[],
  filePath?: string,
): Record<string, string> {
  const rendered: Record<string, string> = {};
  for (const [label, description] of Object.entries(criteria)) {
    const expandedFiles =
      filePath !== undefined
        ? [filePath]
        : hasFileTemplate(label) || hasFileTemplate(description)
          ? files
          : [undefined];
    for (const currentFile of expandedFiles) {
      const renderedLabel = currentFile === undefined ? label : renderFileTemplate(label, currentFile);
      const renderedDescription =
        currentFile === undefined ? description : renderFileTemplate(description, currentFile);
      if (renderedLabel in rendered) throw new Error(`Expanded answer labels collide: "${renderedLabel}"`);
      rendered[renderedLabel] = renderedDescription;
    }
  }
  return rendered;
}

function renderQuestion(
  question: GlobQuestion,
  files: string[],
  filePath?: string,
): GlobQuestion {
  const instructions =
    filePath === undefined ? question.instructions : renderFileTemplate(question.instructions, filePath);
  if (question.type === "choice") {
    return { type: "choice", instructions, criteria: renderChoiceCriteria(question.criteria, files, filePath) };
  }
  if (question.type === "score") {
    const criteria = filePath === undefined
      ? question.criteria.flatMap(criterion =>
          hasFileTemplate(criterion) ? files.map(file => renderFileTemplate(criterion, file)) : [criterion],
        )
      : question.criteria.map(criterion => renderFileTemplate(criterion, filePath));
    return { type: "score", instructions, criteria };
  }
  return { type: "noul", instructions };
}

async function readFileContents(filePaths: string[], cwd: string): Promise<Record<string, string>> {
  const fileContents: Record<string, string> = {};
  let totalChars = 0;

  for (const filePath of filePaths) {
    const resolved = path.isAbsolute(filePath) ? filePath : path.resolve(cwd, filePath);
    let content: string;
    try {
      content = await fs.readFile(resolved, "utf-8");
    } catch (err) {
      throw new Error(`Cannot read "${filePath}": ${(err as Error).message}`);
    }

    const remaining = MAX_TOTAL_CHARS - totalChars;
    if (remaining <= 0) {
      fileContents[filePath] = "[omitted: total file budget exhausted]";
      continue;
    }
    if (content.length > remaining) {
      content = content.slice(0, remaining) + `\n[truncated — ${content.length - remaining} chars omitted]`;
    }
    fileContents[filePath] = content;
    totalChars += content.length;
  }
  return fileContents;
}

async function askDecisionModel(
  state: Record<string, string>,
  questions: Record<string, unknown>,
  signal: AbortSignal,
) {
  const base = (process.env.LLAMA_BASE_URL ?? "http://localhost:8080/v1")
    .replace(/\/+$/, "")
    .replace(/\/v1$/, "");
  const res = await fetch(`${base}/v1/systemone`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: DECISION_MODEL, state, questions }),
    signal,
  });
  if (!res.ok) throw new Error(`Decision model request failed (${res.status}): ${await res.text()}`);
  return ((await res.json()) as any).answers;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "file_question",
    description:
      "Classify one or more files with a local decision model and return exactly one supplied answer label, " +
      "without the file contents ever entering your context. " +
      "This is a bounded yes/no or multiple-choice tool, not a search or extraction tool: it cannot return " +
      "every match, paths, line numbers, exact values, commands, or quotes. " +
      "Use it for one decision such as whether X exists, which option applies, or what kind of file it is, " +
      "especially when the files are large or numerous and only the decision is needed. " +
      "For a few small files, direct inspection may be simpler because this tool's call overhead can outweigh " +
      "its context savings. For lists, exhaustive references, exact text, or multi-part inventories, inspect the " +
      "files directly. When using this tool, provide mutually exclusive, collectively covering answer labels.",
    promptSnippet: "Classify large or numerous files with one bounded multiple-choice question; do not use for extraction",
    promptGuidelines: [
      "Use file_question only for one bounded yes/no or multiple-choice decision about file contents.",
      "It is most useful when the files are large or numerous and the main model only needs the decision; for a few small files, direct inspection may be simpler.",
      "Do not use it for lists, exhaustive searches, paths, line numbers, exact values, commands, quotes, or multi-part inventories: it returns only one answer label, not extracted findings.",
      "Provide mutually exclusive, collectively covering answer labels with a short description of when each applies.",
    ],
    annotations: { readOnlyHint: true, idempotentHint: true },
    parameters: FileQuestionParams,

    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      // Read files and assemble state within context budget
      const fileContents: Record<string, string> = {};
      let totalChars = 0;

      for (const filePath of params.files) {
        const resolved = path.isAbsolute(filePath)
          ? filePath
          : path.resolve(ctx.cwd, filePath);

        let content: string;
        try {
          content = await fs.readFile(resolved, "utf-8");
        } catch (err) {
          throw new Error(`Cannot read "${filePath}": ${(err as Error).message}`);
        }

        const remaining = MAX_TOTAL_CHARS - totalChars;
        if (remaining <= 0) {
          fileContents[filePath] = "[omitted: total file budget exhausted]";
          continue;
        }
        if (content.length > remaining) {
          // shortcut: truncates mid-content; upgrade to line-aware truncation if needed
          content =
            content.slice(0, remaining) +
            `\n[truncated — ${content.length - remaining} chars omitted]`;
        }
        fileContents[filePath] = content;
        totalChars += content.length;
      }

      // Decision models are served on /v1/systemone, not via chat logits.
      const base = (process.env.LLAMA_BASE_URL ?? "http://localhost:8080/v1").replace(/\/+$/, "").replace(/\/v1$/, "");
      const res = await fetch(`${base}/v1/systemone`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: DECISION_MODEL,
          state: fileContents,
          questions: { answer: { type: "choice", instructions: params.question, criteria: params.answers } },
        }),
        signal,
      });
      if (!res.ok) throw new Error(`Decision model request failed (${res.status}): ${await res.text()}`);
      const answer = ((await res.json()) as any).answers?.answer;
      if (!answer || answer.type !== "choice") {
        throw new Error(`Unexpected answer from decision model: ${JSON.stringify(answer)}`);
      }

      const { choice, probabilities, confidence } = answer;

      const topProbs = Object.entries(probabilities)
        .sort(([, a], [, b]) => b - a)
        .map(([label, p]) => `${label}: ${Math.round(p * 100)}%`)
        .join(", ");

      const text =
        `**${choice}** (confidence ${Math.round(confidence * 100)}%)\n\n` +
        `Probabilities: ${topProbs}\n\n` +
        `Files: ${params.files.join(", ")}\n` +
        `Question: ${params.question}`;

      return {
        content: [{ type: "text", text }],
        details: { choice, confidence, probabilities, files: params.files },
      };
    },
  });

  pi.registerTool({
    name: "file_glob_question",
    description:
      "Match files with a glob and run classifier questions with a local decision model, without file contents entering " +
      "your context. The questions object mirrors the classifier question format: choice, score, or bool. Put {{file}} " +
      "in a question ID or instructions to expand it once per matched file, for example " +
      "{\"inside_{{file}}\": {\"type\": \"bool\", \"instructions\": \"Is {{file}} bad?\", " +
      "\"criteria\": {\"true\": \"It is bad\", \"false\": \"It is not bad\"}}}. " +
      "Without {{file}}, a question runs once over all matches. In choice or score criteria, {{file}} expands options " +
      "per matched file. This returns classifier answers only, not extracted text or exhaustive findings.",
    promptSnippet: "Run templated classifier questions over files matched by a glob",
    promptGuidelines: [
      "Use for bounded classifier questions over files matched by a glob.",
      "Use a question object with type, instructions, and criteria where applicable, matching the classifier format: choice, score, or noul.",
      "{{file}} in a question ID or instructions creates one question per matched file; without it, the question runs once over all matches.",
      "{{file}} in choice or score criteria expands that criterion for each matched file; the tool returns answers, not file contents or an extracted inventory.",
    ],
    annotations: { readOnlyHint: true, idempotentHint: true },
    parameters: FileGlobQuestionParams,

    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      const files: string[] = [];
      for await (const match of fs.glob(params.glob, { cwd: ctx.cwd })) {
        const filePath = path.resolve(ctx.cwd, match);
        if ((await fs.stat(filePath)).isFile()) files.push(match);
      }
      files.sort();
      if (files.length === 0) throw new Error(`Glob matched no files: "${params.glob}"`);
      if (Object.keys(params.questions).length === 0) throw new Error("At least one question is required");

      const state = await readFileContents(files, ctx.cwd);
      const questions: Record<string, unknown> = {};
      for (const [questionId, question] of Object.entries(params.questions) as [string, GlobQuestion][]) {
        const perFile = hasFileTemplate(questionId) || hasFileTemplate(question.instructions);
        for (const filePath of perFile ? files : [undefined]) {
          const expandedId = filePath === undefined ? questionId : renderFileTemplate(questionId, filePath);
          if (expandedId in questions) throw new Error(`Expanded question IDs collide: "${expandedId}"`);
          questions[expandedId] = renderQuestion(question, files, filePath);
        }
      }

      const modelAnswers = await askDecisionModel(state, questions, signal);
      const results = Object.entries(questions).map(([questionId]) => {
        const answer = modelAnswers?.[questionId];
        if (!answer) throw new Error(`Unexpected answer for "${questionId}": ${JSON.stringify(answer)}`);
        if (answer.type === "choice") {
          const topProbs = Object.entries(answer.probabilities)
            .sort(([, a], [, b]) => b - a)
            .map(([label, probability]) => `${label}: ${Math.round((probability as number) * 100)}%`)
            .join(", ");
          return `- ${questionId}: **${answer.choice}** (confidence ${Math.round(answer.confidence * 100)}%)\n  Probabilities: ${topProbs}`;
        }
        if (answer.type === "score") {
          return `- ${questionId}: **${answer.score}** (confidence ${Math.round(answer.confidence * 100)}%)`;
        }
        if (answer.type === "noul") {
          return `- ${questionId}: ${JSON.stringify(answer)}`;
        }
        throw new Error(`Unexpected answer type for "${questionId}": ${JSON.stringify(answer)}`);
      });

      return {
        content: [{
          type: "text",
          text: `Glob: ${params.glob}\nFiles (${files.length}): ${files.join(", ")}\n\n${results.join("\n")}`,
        }],
        details: { glob: params.glob, files, answers: modelAnswers },
      };
    },
  });
}
