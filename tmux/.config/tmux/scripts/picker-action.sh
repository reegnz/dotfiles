#!/usr/bin/env bash
# picker-action.sh <action> <repo-root> [branch-or-query]
# Branch actions are guarded here because fzf keeps bindings installed while
# switching between the branch and PR views.
set -uo pipefail
action="${1:?usage: picker-action.sh action repo-root [value]}"
root="${2:?usage: picker-action.sh action repo-root [value]}"
value="${3:-}"
here="$(dirname "$0")"

case "${FZF_PROMPT:-}" in
  prs*)
    # Fetch is useful in either view; create/delete/pull are branch-only and
    # must not interpret a PR number as a branch name.
    [[ "$action" == fetch ]] || exit 0
    ;;
esac

case "$action" in
  create) git -C "$root" branch -- "$value" ;;
  remove) "$here/tmux-worktree.sh" remove "$root" "$value" ;;
  fetch)  git -C "$root" fetch --all --prune ;;
  pull)   "$here/branch-pull.sh" "$root" "$value" ;;
  *)      echo "picker-action.sh: unknown action: $action" >&2; exit 2 ;;
esac
