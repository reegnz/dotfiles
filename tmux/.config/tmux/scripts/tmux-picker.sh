#!/usr/bin/env bash
# tmux session picker.
#
# Step 1  pick a directory (alt-c rotates zoxide / fd / ghq sources).
# Step 2  if it's a git repo with commits, drill into its branches; opening one
#         lands in a per-worktree window. Otherwise switch to / create the repo
#         or directory's "ai" session.
#
# All fzf-binding logic lives in sibling scripts (dir-source.sh, *-for-path.sh,
# branch-source.sh, branch-toggle-remotes.sh); this file is just orchestration.
set -uo pipefail

scripts="$HOME/.config/tmux/scripts"
dir_source="$scripts/dir-source.sh"
kill_session="$scripts/kill-session-for-path.sh"
session_for_path="$scripts/session-for-path.sh"
branch_source="$scripts/branch-source.sh"
branch_pull="$scripts/branch-pull.sh"
toggle_remotes="$scripts/branch-toggle-remotes.sh"
worktree="$scripts/tmux-worktree.sh"

if command -v eza >/dev/null; then
  preview='eza -1 --icons --group-directories-first --color=always'
else
  preview='ls -lah'
fi

# ── Step 1: pick a directory ────────────────────────────────────────────────
path=$(
  fzf --ansi --disabled --tmux --layout=reverse --info=inline --keep-right \
    --accept-nth 2.. \
    --prompt 'zoxide > ' \
    --header 'alt-c: source   alt-d: kill session   alt-p: preview' \
    --preview "$preview {2..}" --preview-window '25%,~1' \
    --bind "start:reload($dir_source list zoxide)" \
    --bind "change:reload($dir_source list zoxide {q})" \
    --bind "alt-c:transform:$dir_source cycle" \
    --bind "alt-d:execute-silent($kill_session {2..})+transform:$dir_source reload" \
    --bind 'alt-p:toggle-preview' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-f:page-down,ctrl-b:page-up'
)
[ -z "$path" ] && exit 0

# Outside tmux: just print the chosen path.
[ -z "${TMUX:-}" ] && {
  printf '%s\n' "$path"
  exit 0
}

session=$("$session_for_path" "$path")

# ── Step 2a: not a git repo (or unborn) → switch to / create its "ai" session ──
# (--verify HEAD is false for both non-repos and unborn repos, which can't seed a
#  worktree, so they get the plain-directory handling.)
if ! git -C "$path" rev-parse --quiet --verify HEAD >/dev/null 2>&1; then
  [ -n "$session" ] && exec tmux switch-client -t "$session"
  (cd "$path" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session ai)
  session=$("$session_for_path" "$path")
  [ -n "$session" ] && exec tmux switch-client -t "$session"
  exit 0
fi

# ── Step 2b: a git repo with commits → drill into its branches ─────────────────
root=$(git -C "$path" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
label=" ${root} "
[ -n "$session" ] && label=" ${session}  ·  ${root} "

# Branches load from the start bind via branch-source.sh, which reads the prompt
# for the mode (local / local+remote) — so every reload keeps the showing mode.
# enter: open the highlighted branch ({2} is the bare name — field 1 is the glyph,
#        fields 3+ are the ahead/behind suffix); tmux-worktree.sh makes/focuses the
#        window and switches to it.
# alt-c: create the typed branch if new, then reload — the query is kept, so the
#        list re-filters onto the new branch, ready to open with enter.
# alt-d: delete the highlighted branch — tmux-worktree.sh drops its worktree (and
#        window) first, prompting to force when the worktree is dirty/unmerged.
# ctrl-f: fetch all remotes (with prune), then reload to pick up new/gone branches.
# ctrl-p: fast-forward the highlighted branch from its upstream, then reload —
#         branch-pull.sh pulls in its worktree if checked out, else updates the ref.
# ctrl-r: flip local <-> local+remote.
fzf --ansi --tmux --layout=reverse --info=inline --keep-right \
  --prompt 'branches(local) > ' --border --border-label "$label" \
  --header 'enter: open   alt-c: create   alt-d: delete   ctrl-f: fetch   ctrl-p: pull   ctrl-r: toggle remotes' \
  --bind "start:reload($branch_source '$root')" \
  --bind "enter:become($worktree open '$root' {2})" \
  --bind "alt-c:execute-silent(git -C '$root' branch -- {q})+reload($branch_source '$root')" \
  --bind "alt-d:execute($worktree remove '$root' {2})+reload($branch_source '$root')" \
  --bind "ctrl-f:execute(git -C '$root' fetch --all --prune)+reload($branch_source '$root')" \
  --bind "ctrl-p:execute($branch_pull '$root' {2})+reload($branch_source '$root')" \
  --bind "ctrl-r:transform:$toggle_remotes '$root'" \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'
exit 0 # swallow fzf's abort code (130 on esc) so tmux run-shell doesn't flag it
