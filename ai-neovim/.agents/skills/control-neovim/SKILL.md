---
name: control-neovim
description: >-
  How to drive a listening Neovim over RPC. Use when
  the user asks something like 'show me', 'show me where', 'open in neovim',
  'open in a buffer', 'jump to', 'go to line', 'what file is open', 'what is
  selected', 'show diagnostics', 'open diff', 'compare files'.
disable-model-invocation: false
---

# Control Neovim

Agents use the `nvim` binary as a client. All scripts live in `scripts/` under this skill.

## Starting a new instance

```
nvim-start-tmux <dir>
```

Requires tmux. Without tmux, ask the user to open Neovim in the target directory and run `:NvimListen`.

---

# Querying state

```
nvim-read-current [--server <socket>]
```
Print active file, line, and column as `<path>:<line>:<col>`.

```
nvim-read-buffers [--server <socket>]
```
List open buffers as `<bufnr>\t<absolute-path>`, one per line.

```
nvim-read-selection [--server <socket>]
```
Print the content of the last visual selection (full lines).

```
nvim-read-diagnostics [--server <socket>]
```
Print LSP diagnostics for the current buffer as `<line>:<col>: [<severity>] (<source>) <message>`.

```
nvim-open-diff [--server <socket>] <file1> <file2>
```
Open two files side-by-side in vimdiff (new tab, vertical split). Use this to
show the diff of a before/after pair — equivalent to the IDE integration's
native diff viewer.

---

# Navigating ("show me")

```
nvim-write-quickfix [--server <socket>] [--efm <errorformat>] < entries
```

Reads entries from stdin (one per line), populates the quickfix list, and jumps
to the first entry. Safe to whitelist. Without `--efm`, Neovim's current
errorformat is used unchanged.

```bash
# Tool output with messages matches Neovim's default efm — no --efm needed:
nvim-write-quickfix <<EOF
src/foo.py:42:7:undefined variable 'x'
src/bar.py:15:1:missing return statement
EOF

# Plain locations without messages need an explicit efm:
nvim-write-quickfix --efm '%f:%l:%c,%f:%l,%f' <<EOF
src/foo.py:42:7
src/bar.py:15
src/baz.py
EOF
```

```
nvim-read-quickfix [--server <socket>]
```

Prints the current quickfix list as `file:line:col` entries, one per line.

## Visual selection (line range)

```bash
nvim --server "$NVIM_ADDR" --headless \
  --remote-expr "execute('e /abs/path/to/file.txt | call cursor(3, 1) | normal! V5G')"
```

---

## Caveats

- **Always pass `--headless`** when using `nvim` as a client; omitting it causes the
  terminal to emit a flood of escape sequences.
- **`--server` must precede `--remote*` flags** on the command line or the connection
  is not established.
- **Any process that can open the listen address can drive the editor.** Avoid piping
  untrusted text into `--remote-expr`; stick to fixed patterns like the snippets above.
- **File opened in awkward window**: `--remote` does not apply `pick_win`; use Lua
  when terminals must stay put.
- **Highlight not visible**: wrong buffer, or highlight group missing in the active
  colorscheme.
