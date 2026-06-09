---
name: control-neovim
description: >-
  How to drive a listening Neovim over RPC. Use when the user asks something
  like 'show me', 'show me where', 'walk me through', 'where is', 'open in
  neovim', 'open in a buffer', 'jump to', 'go to line', 'what file is open',
  'what is selected', 'show diagnostics', 'open diff', 'compare files'.
disable-model-invocation: false
allowed-tools:
  - Bash(scripts/*)
---

# Control Neovim

**Never try to find or resolve the Neovim server yourself.** The scripts handle
server resolution automatically. Just run them.

---

## Querying state

```bash
./scripts/nvim-read-current
```

Print active file, line, and column as `<path>:<line>:<col>`.

```bash
./scripts/nvim-read-buffers
```

List open buffers as `<bufnr>\t<absolute-path>`, one per line.

```bash
./scripts/nvim-read-selection
```

Print the content of the last visual selection (full lines).

```bash
./scripts/nvim-read-diagnostics
```

Print LSP diagnostics for the current buffer as
`<line>:<col>: [<severity>] (<source>) <message>`.

```bash
./scripts/nvim-read-workspace-diagnostics
```

Print LSP diagnostics across all loaded buffers as
`<absolute-path>:<line>:<col>: [<severity>] (<source>) <message>`.

```bash
./scripts/nvim-read-symbols
```

Print LSP document symbols for the current buffer as `<line>:<kind>:<name>`,
indented to reflect nesting. Useful for understanding a file's structure before
navigating into it.

```bash
./scripts/nvim-open-diff <file1> <file2>
```

Open two files side-by-side in vimdiff (new tab, vertical split). Use this to
show the diff of a before/after pair — equivalent to the IDE integration's
native diff viewer.

---

## Navigating ("show me")

**Prefer `nvim-write-quickfix` for navigation.** It populates a list the user
can step through and provides context messages. Use `nvim-goto` only when the
quickfix list is already populated and you need to show a related location
without clobbering it.

```bash
./scripts/nvim-goto <file> [<line> [<col>]]
```

Open a file, optionally jumping to a line and column.

```bash
./scripts/nvim-write-quickfix [--efm <errorformat>] < entries
```

Reads entries from stdin (one per line), populates the quickfix list, and jumps
to the first entry. Always pass entries via heredoc, not a pipe.

Always include a message on every entry explaining why that location is in the
list (e.g. "definition", "caller", "TODO"). The default errorformat matches
`file:line:col:message` — use it whenever your entries fit that shape. Only
pass `--efm` when they don't.

```bash
./scripts/nvim-write-quickfix <<EOF
src/foo.py:42:7:undefined variable 'x'
src/bar.py:15:1:missing return statement
EOF
```

```bash
./scripts/nvim-read-quickfix
```

Prints the current quickfix list as `file:line:col:message` entries, one per
line.

```bash
./scripts/nvim-quickfix-navigate <first|last|next|previous>
```

Jump to an entry in the quickfix list.

```bash
./scripts/nvim-search <pattern>
```

Set the search register and enable `hlsearch` so all occurrences of `pattern`
are highlighted in the editor. Vim's default magic applies (same as typing
`/pattern`).

```bash
./scripts/nvim-annotate < entries
```

Read `file:line:col:text` entries from stdin and add virtual text annotations
at each location (shown after the line, styled as a comment). Text may contain
colons. Always pass entries via heredoc, not a pipe.

```bash
./scripts/nvim-annotate <<EOF
src/foo.py:42:1:bug: off-by-one here
src/foo.py:58:5:this path is unreachable
EOF
```

```bash
./scripts/nvim-clear-annotations
```

Remove all virtual text annotations added by `nvim-annotate`.
