#!/usr/bin/env bash
# picker-open.sh <repo-root> <branch-or-pr>
# Dispatch enter to the correct worktree action for the active picker view.
set -eu
root="${1:?usage: picker-open.sh <repo-root> <branch-or-pr>}"
item="${2:?usage: picker-open.sh <repo-root> <branch-or-pr>}"
worktree="$(dirname "$0")/tmux-worktree.sh"
case "${FZF_PROMPT:-}" in
  prs*) exec "$worktree" open-pr "$root" "$item" ;;
  *)     exec "$worktree" open "$root" "$item" ;;
esac
