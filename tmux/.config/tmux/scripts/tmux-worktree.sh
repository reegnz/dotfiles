#!/usr/bin/env bash
# tmux-worktree.sh open|remove <repo-root> <branch>
#   open    ensure <branch> has a worktree + window in the repo's session, focus it
#   remove  drop <branch>'s worktree (and its window) and delete the branch
# One window per worktree; the main checkout is the root window. Worktrees live
# under <repo-root>/.worktrees/<branch>. Driven by tmux-picker.sh.
set -euo pipefail
[[ -z "${TMUX:-}" ]] && exit 0

action="${1:?usage: tmux-worktree.sh open|remove <repo-root> <branch>}"
root="${2:?usage: tmux-worktree.sh open|remove <repo-root> <branch>}"
branch="${3:?usage: tmux-worktree.sh open|remove <repo-root> <branch>}"
session_for_path="$(dirname "$0")/session-for-path.sh"

git_root() { git -C "$root" "$@"; }

# True if $branch is already absorbed into HEAD — by real merge, rebase, OR squash.
# Merge the branch into HEAD in-memory: if the branch adds nothing, the result is
# just HEAD's tree. Catches squashes that --is-ancestor/-d miss. (git >= 2.38;
# --write-tree only writes a dangling tree object, no refs/index/worktree touched.)
is_merged() {
  local merged
  merged=$(git_root merge-tree --write-tree HEAD "$branch") || return 1  # conflict => not merged
  [[ "$merged" == "$(git_root rev-parse "HEAD^{tree}")" ]]
}

# This branch's worktree path, straight from git (empty if it has none).
existing_worktree=$(git_root for-each-ref --format='%(worktreepath)' "refs/heads/$branch")

case "$action" in
  open)
    worktree="${existing_worktree:-$root/.worktrees/$branch}"  # existing one, else where to create it

    # Ensure the repo's session exists, then switch to it.
    session=$("$session_for_path" "$root")
    if [[ -z "$session" ]]; then
      ( cd "$root" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session ai )
      session=$("$session_for_path" "$root")
    fi
    tmux switch-client -t "$session"

    # If a window already sits in that worktree, focus it. Match on @window_root
    # (the worktree path ai.window.sh stamps on the window), not pane_current_path —
    # the latter drifts when a pane cd's away, leaving a duplicate window unmatched.
    window=$(tmux list-windows -t "$session" -f "#{==:#{@window_root},$worktree}" -F '#{window_index}')
    if [[ -n "$window" ]]; then
      tmux select-window -t "$session:$window"
      exit 0
    fi

    # Otherwise create the worktree (if missing), then load a window for it.
    if [[ ! -d "$worktree" ]]; then
      if git_root show-ref --verify --quiet "refs/heads/$branch"; then
        git_root worktree add "$worktree" "$branch"                         # existing local branch
      elif remote=$(git_root for-each-ref --count=1 --format='%(refname:short)' "refs/remotes/*/$branch") \
           && [[ -n "$remote" ]]; then
        git_root worktree add "$worktree" -b "$branch" --track "$remote"    # track a remote branch
      else
        git_root worktree add "$worktree" -b "$branch"                      # brand-new branch
      fi
    fi
    ( cd "$worktree" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-window ai )
    ;;

  remove)
    # Force needed if the worktree is dirty or the branch isn't merged into HEAD.
    force=
    if [[ -n "$existing_worktree" && -n "$(git -C "$existing_worktree" status --porcelain)" ]]; then force=1; fi
    is_merged || force=1
    if [[ -n "$force" ]]; then
      read -rp "Force-delete '$branch'? Drops its worktree and any unmerged/uncommitted work. [y/N] " ans
      [[ $ans == [yY]* ]] || exit 0
    fi

    # Close the worktree's window (if open), drop the worktree, then the branch.
    if [[ -n "$existing_worktree" ]]; then
      session=$("$session_for_path" "$root")
      if [[ -n "$session" ]]; then
        window=$(tmux list-windows -t "$session" -f "#{==:#{@window_root},$existing_worktree}" -F '#{window_index}')
        [[ -n "$window" ]] && tmux kill-window -t "$session:$window"
      fi
      if [[ -n "$force" ]]; then git_root worktree remove --force "$existing_worktree"; else git_root worktree remove "$existing_worktree"; fi
    fi
    if [[ -n "$force" ]]; then git_root branch -D "$branch"; else git_root branch -d "$branch"; fi
    ;;

  *)
    echo "usage: tmux-worktree.sh open|remove <repo-root> <branch>" >&2
    exit 2
    ;;
esac
