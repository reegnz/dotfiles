#!/usr/bin/env bash
# tmux-agent.sh launch <repo-root> <branch> -- <agent-command> [args...]
# Create/focus a worktree window through tmux-worktree.sh, then start an agent
# in that window. The command and arguments are sent through the shell in the
# new pane after being safely shell-quoted.
set -euo pipefail

usage() {
  echo "usage: tmux-agent.sh launch <repo-root> <branch> -- <agent-command> [args...]" >&2
  exit 2
}

[[ "${1:-}" == launch ]] || usage
[[ -n "${TMUX:-}" ]] || {
  echo "tmux-agent.sh: this command must run inside tmux" >&2
  exit 1
}

root_arg="${2:-}"
branch="${3:-}"
[[ -n "$root_arg" && -n "$branch" && "${4:-}" == -- ]] || usage
shift 4
[[ $# -gt 0 ]] || usage

root="$(git -C "$root_arg" rev-parse --show-toplevel)"
common_git_dir="$(git -C "$root" rev-parse --path-format=absolute --git-common-dir)"
root="$(cd "$(dirname "$common_git_dir")" && pwd)"
git -C "$root" check-ref-format --branch "$branch" >/dev/null

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
worktree_tool="${TMUX_WORKTREE_SCRIPT:-$here/tmux-worktree.sh}"
session_for_path="${TMUX_SESSION_FOR_PATH_SCRIPT:-$here/session-for-path.sh}"
[[ -x "$worktree_tool" ]] || { echo "tmux-agent.sh: not executable: $worktree_tool" >&2; exit 1; }
[[ -x "$session_for_path" ]] || { echo "tmux-agent.sh: not executable: $session_for_path" >&2; exit 1; }

"$worktree_tool" open "$root" "$branch"

# Resolve the actual path after open: this also handles an existing worktree or
# a branch that was created from a remote ref.
worktree="$(git -C "$root" for-each-ref --format='%(worktreepath)' "refs/heads/$branch")"
worktree="${worktree:-$root/.worktrees/$branch}"
session="$("$session_for_path" "$root")"
[[ -n "$session" ]] || {
  echo "tmux-agent.sh: no tmux session found for $root" >&2
  exit 1
}

# @window_root is stamped by layouts/default.window.sh and is more reliable than a
# pane's current directory, which can change after the agent starts.
window="$(tmux list-windows -t "$session" -F '#{window_id}\t#{@window_root}' |
  awk -F '\t' -v root="$worktree" '$2 == root && !found { print $1; found=1 }')"
[[ -n "$window" ]] || {
  echo "tmux-agent.sh: no tmux window found for worktree: $worktree" >&2
  exit 1
}

pane="$(tmux list-panes -t "$window" -F '#{pane_id}' | awk 'NR == 1 { print }')"
current_command="$(tmux display-message -p -t "$pane" '#{pane_current_command}')"
case "$current_command" in
  bash|zsh|fish|sh|dash|ksh|tcsh|csh|nu|xonsh) ;;
  *)
    if [[ "${TMUX_AGENT_FORCE:-0}" != 1 ]]; then
      echo "tmux-agent.sh: pane $pane is already running '$current_command'; set TMUX_AGENT_FORCE=1 to replace it" >&2
      exit 1
    fi
    ;;
esac

printf -v launch_command '%q ' "$@"
launch_command="${launch_command% }"
tmux select-window -t "$window"
tmux select-pane -t "$pane"
tmux send-keys -t "$pane" "$launch_command" C-m

printf 'Launched agent in %s (%s)\n' "$worktree" "$window"
