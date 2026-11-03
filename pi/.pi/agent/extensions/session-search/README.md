# session-search

A pi extension. It adds a `session_search(query, limit?, includeToolOutput?, folder?, global?)` tool that searches
past sessions with SQLite FTS5 and BM25 ranking.

- Indexes user text, assistant text, bash commands and tool output from
  `~/.pi/agent/sessions/**/*.jsonl`. Thinking is skipped. Each entry is capped at 4000 characters.
- Tool output is excluded from search by default. Pass `includeToolOutput: true` to include it.
- `limit` is 1 to 50 (default 8). `folder` takes a directory path. Git lists the main checkout and all current worktrees of that repo, and the search covers them. It defaults to the current directory. Outside a git repo, only that directory is searched. Worktrees deleted since their sessions were recorded are not searched. `global: true` searches all sessions instead.
- Every search first re-indexes files whose size or mtime changed, and drops
  files that were deleted.
- Query words are quoted. Entries with all the words come first, then entries with some of them fill the rest.
- Database: `~/.pi/agent/session-index.db`. Safe to delete; it is rebuilt.
- Self-check: `node --experimental-strip-types check.ts`

Known limits: bash commands can outrank prose; there is no context around a
hit (open the session file at the entry id instead).
