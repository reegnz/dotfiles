#!/usr/bin/env bash
# tmux session picker.
#
# Step 1  pick a directory (alt-c rotates zoxide / fd / ghq sources).
# Step 2  if it's a git repo with commits, drill into its branches; opening one
#         lands in a per-worktree window. Otherwise switch to / create the repo
#         or directory's "default" session.
#
# All fzf-binding logic lives in sibling scripts (dir-source.sh, branch-source.sh,
# pr-source.sh, picker-*.sh); this file is just orchestration.
set -uo pipefail

scripts="$HOME/.config/tmux/scripts"
dir_source="$scripts/dir-source.sh"
kill_session="$scripts/kill-session-for-path.sh"
session_for_path="$scripts/session-for-path.sh"
branch_source="$scripts/branch-source.sh"
picker_reload="$scripts/picker-reload.sh"
picker_toggle="$scripts/picker-toggle.sh"
picker_toggle_remotes="$scripts/picker-toggle-remotes.sh"
picker_open="$scripts/picker-open.sh"
picker_action="$scripts/picker-action.sh"

if command -v eza >/dev/null; then
  preview='eza -1 --icons --group-directories-first --color=always'
else
  preview='ls -lah'
fi

# ── Step 1: pick a directory ────────────────────────────────────────────────
while :; do
path=$(
  fzf --ansi --disabled --tmux 'center,90%,90%' --layout=reverse --info=inline --keep-right \
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

# ── Step 2a: not a git repo (or unborn) → switch to / create its "default" session ──
# (--verify HEAD is false for both non-repos and unborn repos, which can't seed a
#  worktree, so they get the plain-directory handling.)
if ! git -C "$path" rev-parse --quiet --verify HEAD >/dev/null 2>&1; then
  [ -n "$session" ] && exec tmux switch-client -t "$session"
  (cd "$path" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session default)
  session=$("$session_for_path" "$path")
  [ -n "$session" ] && exec tmux switch-client -t "$session"
  exit 0
fi

# ── Step 2b: a git repo with commits → drill into branches or PRs ───────────────
root=$(git -C "$path" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
label=" ${root} "
[ -n "$session" ] && label=" ${session}  ·  ${root} "

# The second stage starts with branches and alt-p switches it to open GitHub PRs.
# Every action is dispatched through a small helper because fzf keeps bindings
# installed while the view changes; in particular, a PR number must never be
# passed to the branch delete/pull actions.
#   enter   open the highlighted branch or PR in its worktree window
#   alt-p   switch between branches and open PRs
#   ctrl-r  flip local <-> local+remote (branch view only)
#   ctrl-f  fetch all remotes, then reload the active view
#   ctrl-p  pull the highlighted branch (no-op in the PR view)
#   esc     back to the directory list (esc there closes the picker)
action=$(fzf --ansi --tmux 'center,90%,90%' --layout=reverse --info=inline --keep-right \
  --prompt 'branches(local) > ' --border --border-label "$label" \
  --header 'enter: open   alt-p: toggle PRs   alt-c: create   alt-d: delete   ctrl-f: fetch   ctrl-p: pull   ctrl-r: toggle remotes   esc: back' \
  --bind "start:reload($branch_source '$root')" \
  --bind "enter:become($picker_open '$root' {2})" \
  --bind "alt-p:transform:$picker_toggle '$root'" \
  --bind "alt-c:execute-silent($picker_action create '$root' {q})+transform:$picker_reload '$root'" \
  --bind "alt-d:execute($picker_action remove '$root' {2})+transform:$picker_reload '$root'" \
  --bind "ctrl-f:execute($picker_action fetch '$root')+transform:$picker_reload '$root'" \
  --bind "ctrl-p:execute($picker_action pull '$root' {2})+transform:$picker_reload '$root'" \
  --bind "ctrl-r:transform:$picker_toggle_remotes '$root'" \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up' \
  --bind 'esc:become(printf back)')
[ "$action" = back ] && continue
exit 0 # swallow fzf's abort code (130 on ctrl-c) so tmux run-shell doesn't flag it
done
