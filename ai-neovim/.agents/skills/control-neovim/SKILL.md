---
name: control-neovim
description: >-
  How to drive a listening Neovim over RPC. Use when the user asks something
  like 'show me', 'show me where', 'walk me through', 'where is this in neovim',
  'open in neovim', 'open in a buffer', 'jump to', 'go to line', 'what file is open',
  'what is selected', 'show diagnostics', 'open diff', 'compare files'.
allowed-tools:
  - Bash(scripts/*)
---

# Control Neovim

**Never try to find or resolve the Neovim server yourself.** The scripts handle server resolution automatically. Just run them.

**Scripts connect to a Unix socket** and require sandbox bypass to connect. Run each script with `dangerouslyDisableSandbox: true`.

**Alternatively**, if you'd prefer not to bypass the sandbox on every call, you can allow Unix sockets at the settings level — ask the user: *"Would you like to add `allowAllUnixSockets: true` to this project's `settings.local.json`? This avoids per-call sandbox bypasses but grants access to all Unix sockets on the machine."* If yes, use the `update-config` skill to add it under `sandbox.network`.

**If a script exits non-zero, Neovim is likely not listening — tell the user.**

**Always quote arguments** derived from file paths or user input to prevent shell injection.

---

## Query state

| Script | Output |
|--------|--------|
| `./scripts/nvim-read-current` | Active file/line/col as `path:line:col` |
| `./scripts/nvim-read-buffers` | Open buffers as `bufnr\tpath` |
| `./scripts/nvim-read-selection` | Last visual selection (full lines) |
| `./scripts/nvim-read-diagnostics` | LSP diagnostics for current buffer |
| `./scripts/nvim-read-workspace-diagnostics` | LSP diagnostics across all buffers |
| `./scripts/nvim-read-symbols` | Document symbols as `line:kind:name` (indented) |
| `./scripts/nvim-open-diff <file1> <file2>` | Side-by-side vimdiff in new tab |

## Navigate ("show me")

**Prefer `nvim-write-quickfix` over `nvim-goto`** — it populates a list the user can step through.

| Script | Purpose |
|--------|---------|
| `./scripts/nvim-goto <file> [line [col]]` | Jump to file/line/col |
| `./scripts/nvim-write-quickfix [--efm <fmt>] <<EOF` | Populate quickfix, jump to first entry |
| `./scripts/nvim-read-quickfix` | Print quickfix as `file:line:col:msg` |
| `./scripts/nvim-quickfix-navigate <first\|last\|next\|previous>` | Step through quickfix |
| `./scripts/nvim-search <pattern>` | Highlight pattern in editor |
| `./scripts/nvim-annotate <<EOF` | Add virtual text at `file:line:col:text` |
| `./scripts/nvim-clear-annotations` | Remove all virtual text |
| `./scripts/nvim-marks list` | List all set marks (human-readable table) |
| `./scripts/nvim-marks set <mark> [file:line:col]` | Set mark at location or current position |
| `./scripts/nvim-marks jump <mark>` | Jump to exact mark position |

Pass stdin via heredoc (not pipe). Include a message on every quickfix entry.

```bash
./scripts/nvim-goto "$file" "$line" "$col"
```

```bash
./scripts/nvim-write-quickfix <<EOF
src/foo.py:42:7:undefined variable 'x'
src/bar.py:15:1:missing return statement
EOF
```

```bash
./scripts/nvim-annotate <<EOF
src/foo.py:42:1:⚠ unused variable
EOF
```
