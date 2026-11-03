# skill-loop

A pi extension that builds a personal skill library automatically.
After a substantial agent run, a cheap model reviews the transcript and
creates or updates a skill. The main model never does the review. The
main model finds stored skills through the `skill_search` tool.

## Files

- `~/.pi/agent/extensions/skill-loop/index.ts`
  The extension.
- `~/.pi/agent/extensions/skill-loop/README.md`
  This file.
- `~/.pi/agent/skill-library/<name>/SKILL.md`
  Skills written by the reviewer.
- `~/.pi/agent/skill-library/<name>/SKILL.md.prev`
  Previous version of an updated skill (one-step undo).
- `~/.pi/agent/skill-loop.json`
  Optional configuration.

The library is outside pi's skill scan paths:

- `~/.pi/agent/skills/`
- `~/.agents/skills/`
- project `.agents/skills/`

Skills therefore never enter the system prompt. Only the `skill_search`
tool reads them.

## How it works

1. **Collect.** On `agent_end`, the extension buffers the messages of
   each run.
2. **Trigger.** On `agent_settled`, it continues only if the run was not
   aborted and had at least `minToolCalls` tool results (default 5).
3. **Review.** It sends the serialized transcript, capped at
   `maxTranscriptChars` from the end, plus the full text of every library
   skill, to the configured model via `ctx.modelRegistry.complete()`.
   The model must reply with JSON only:
   - `{"action":"none"}`
   - `{"action":"create"|"update","name":"kebab-case-name",
     "description":"...","body":"..."}`
4. **Validate.** The extension checks the name pattern and length, the
   description length (max 1024), and that the body is non-empty.
   Anything malformed is dropped.
5. **Write.** It writes `SKILL.md` with frontmatter
   (`metadata.generated-by: skill-loop`). On update, it first copies the
   old file to `SKILL.md.prev`.
6. **Notify.** A UI notification reports what changed.

Review runs in the background and never blocks the session. A re-entry
guard allows one review at a time. Errors appear as warnings.

## Configuration

`~/.pi/agent/skill-loop.json`. All keys are optional:

```json
{
  "model": "provider/model-id",
  "minToolCalls": 5,
  "maxTranscriptChars": 60000
}
```

- `model`: the reviewer model as `provider/model-id`. Without it, the
  session's current model is used. Set this to a cheap model. Find ids
  with `/model`.
- `minToolCalls`: minimum tool results in a run before review happens.
- `maxTranscriptChars`: how much of the transcript (counted from the
  end) the reviewer sees.

## The `skill_search` tool

- `query` (optional): keywords matched against skill names and
  descriptions. The top 3 matches are returned with their full text.
- Empty query: returns the first 3 skills in the library.
- No match: returns `No matching skills.`

The tool is registered directly, so it is active in every session.

## The `skill_manage` tool

The agent can manage the library during a session.

- `action`: `create`, `update`, or `delete`.
- `name`: kebab-case skill name.
- `description` and `body`: required for `create` and `update`.

Rules:

- `create` fails if the name exists. `update` fails if it does not.
- `update` keeps the old file as `SKILL.md.prev`.
- `delete` moves the directory to `skill-library/.deleted/<name>-<ms>`.
  Restore it by moving it back.
- Names and fields go through the same validation as the reviewer.

Skills written by `skill_manage` get the same frontmatter and
`generated-by: skill-loop` marker, so they can't be told apart from
reviewer-written skills. The marker shows the skill came from this
extension, not who wrote it.

The post-run reviewer still runs. It is the backstop for work the agent
did not save itself.

## Freshness

No reload or new session is needed. `skill_search` reads the library
from disk on every call, so a new or updated skill is searchable right
away. Nothing is cached, and skills do not enter the system prompt.

## Limits and shortcuts

- **Search is keyword-based.** Scoring is by term overlap on name and
  description. This is fine for a small library. Upgrade to embeddings
  or SQLite FTS5 past about 200 skills.
- **The reviewer gets the whole library.** This works for about 50
  skills. Past that, pass only an index and fetch the relevant bodies.
- **Nothing forces the agent to call `skill_search`.** Its description
  must be clear about when to use it.
- **Skills are not reviewed by a human.** The reviewer can write a
  wrong or stale procedure, and it will influence later sessions. Check
  skills marked `generated-by: skill-loop` now and then. Use
  `SKILL.md.prev` to roll back.
- **Secrets.** The prompt forbids them, but a model can still copy them
  from a transcript. Review before sharing a library.
- **Cost.** Each qualifying run makes one reviewer call. The full
  library is included in every call.
- **Untested end to end.** The parser and search functions were checked
  standalone. The model call and file writes have not run inside pi.

## Troubleshooting

- `model ... not found`: the `model` value does not match a configured
  provider and id.
- No notification after a long run: the run had fewer than
  `minToolCalls` tool results, was aborted, or the reviewer returned
  `none`.
- `skill-loop failed: ...`: the model call or file write threw. The
  message gives the cause.
