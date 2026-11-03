#!/usr/bin/env bash
# tmux-worktree.sh open|open-pr|remove <repo-root> <branch-or-pr>
#   open     ensure a branch has a worktree + window and focus it
#   open-pr  check out a GitHub PR in a dedicated pr/<number> worktree + window
#   remove   drop a branch's worktree (and its window) and delete the branch
# One window per worktree; the main checkout is the root window. Worktrees live
# under <repo-root>/.worktrees/<branch>. Driven by tmux-picker.sh.
set -euo pipefail
[[ -z "${TMUX:-}" ]] && exit 0

action="${1:?usage: tmux-worktree.sh open|open-pr|remove <repo-root> <branch-or-pr>}"
root="${2:?usage: tmux-worktree.sh open|open-pr|remove <repo-root> <branch-or-pr>}"
target="${3:?usage: tmux-worktree.sh open|open-pr|remove <repo-root> <branch-or-pr>}"
session_for_path="$(dirname "$0")/session-for-path.sh"

git_root() { git -C "$root" "$@"; }

# True if $branch is already absorbed into HEAD — by real merge, rebase, OR squash.
# Merge the branch into HEAD in-memory: if the branch adds nothing, the result is
# just HEAD's tree. Catches squashes that --is-ancestor/-d miss. (git >= 2.38;
# --write-tree only writes a dangling tree object, no refs/index/worktree touched.)
is_merged() {
  local branch="$1" merged
  merged=$(git_root merge-tree --write-tree HEAD "$branch") || return 1  # conflict => not merged
  [[ "$merged" == "$(git_root rev-parse "HEAD^{tree}")" ]]
}

ensure_session() {
  session=$("$session_for_path" "$root")
  if [[ -z "$session" ]]; then
    ( cd "$root" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session default )
    session=$("$session_for_path" "$root")
  fi
  tmux switch-client -t "$session"
}

# Return success when the worktree already has a window. Matching @window_root
# rather than pane_current_path avoids duplicates after a pane changes directory.
window_exists() {
  local worktree="$1"
  window=$(tmux list-windows -t "$session" \
    -f "#{==:#{@window_root},$worktree}" -F '#{window_index}')
  [[ -n "$window" ]]
}

load_window() {
  local worktree="$1"
  window_exists "$worktree" && {
    tmux select-window -t "$session:$window"
    return 0
  }
  ( cd "$worktree" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-window default )
}

open_branch() {
  local branch="$1" existing_worktree worktree remote
  existing_worktree=$(git_root for-each-ref --format='%(worktreepath)' "refs/heads/$branch")
  worktree="${existing_worktree:-$root/.worktrees/$branch}"

  ensure_session
  window_exists "$worktree" && {
    tmux select-window -t "$session:$window"
    return 0
  }

  if [[ ! -d "$worktree" ]]; then
    # Branch names commonly contain slashes (for example feat/search). Git can
    # create the leaf directory, but not missing parents under .worktrees.
    mkdir -p "$(dirname "$worktree")"
    if git_root show-ref --verify --quiet "refs/heads/$branch"; then
      git_root worktree add "$worktree" "$branch"                         # existing local branch
    elif remote=$(git_root for-each-ref --count=1 --format='%(refname:short)' "refs/remotes/*/$branch") \
         && [[ -n "$remote" ]]; then
      git_root worktree add "$worktree" -b "$branch" --track "$remote"    # track a remote branch
    else
      git_root worktree add "$worktree" -b "$branch"                      # brand-new branch
    fi
  fi
  load_window "$worktree"
}

open_pr() {
  local pr="$1" branch="pr/$1" existing_worktree worktree
  command -v gh >/dev/null 2>&1 || {
    echo 'tmux-worktree.sh: open-pr requires gh (GitHub CLI)' >&2
    exit 1
  }

  # Use a stable local branch/path per PR. This keeps a PR checkout distinct
  # from a similarly named head branch and lets the picker find it on reload.
  existing_worktree=$(git_root for-each-ref --format='%(worktreepath)' "refs/heads/$branch")
  worktree="${existing_worktree:-$root/.worktrees/pr-$pr}"

  ensure_session
  window_exists "$worktree" && {
    tmux select-window -t "$session:$window"
    return 0
  }

  if [[ -z "$existing_worktree" ]]; then
    [[ ! -e "$worktree" ]] || {
      echo "tmux-worktree.sh: path already exists: $worktree" >&2
      exit 1
    }
    mkdir -p "$(dirname "$worktree")"
    ( cd "$root" && gh pr checkout "$pr" --branch "$branch" --worktree "$worktree" )
  fi
  load_window "$worktree"
}

remove_branch() {
  local branch="$1" existing_worktree default force='' ans session window
  existing_worktree=$(git_root for-each-ref --format='%(worktreepath)' "refs/heads/$branch")

  git_root show-ref --verify --quiet "refs/heads/$branch" || {
    echo "no local branch '$branch' (remote-only branches can't be deleted here)" >&2; exit 1; }
  # Never delete the default branch or the main checkout's branch.
  default=$(git_root symbolic-ref --short -q refs/remotes/origin/HEAD || true)
  if [[ "$branch" == "${default#*/}" || "$existing_worktree" == "$root" ]]; then
    echo "refusing to delete '$branch': it is the default/main branch" >&2; exit 1
  fi

  # Force needed if the worktree is dirty or the branch isn't merged into HEAD.
  if [[ -n "$existing_worktree" && -n "$(git -C "$existing_worktree" status --porcelain)" ]]; then force=1; fi
  is_merged "$branch" || force=1
  if [[ -n "$force" ]]; then
    read -rp "Force-delete '$branch'? Drops its worktree and any unmerged/uncommitted work. [y/N] " ans
    [[ $ans == [yY]* ]] || exit 0
  fi

  # Close the worktree's window (if open), drop the worktree, then the branch.
  if [[ -n "$existing_worktree" ]]; then
    session=$("$session_for_path" "$root")
    if [[ -n "$session" ]]; then
      window=$(tmux list-windows -t "$session" \
        -f "#{==:#{@window_root},$existing_worktree}" -F '#{window_index}')
      [[ -n "$window" ]] && tmux kill-window -t "$session:$window"
    fi
    if [[ -n "$force" ]]; then git_root worktree remove --force "$existing_worktree"; else git_root worktree remove "$existing_worktree"; fi
  fi
  # -D: -d only accepts ancestor merges, so it rejects squash-merged branches that is_merged accepted.
  git_root branch -D "$branch"
}

case "$action" in
  open)    open_branch "$target" ;;
  open-pr) open_pr "$target" ;;
  remove)  remove_branch "$target" ;;
  *)
    echo "usage: tmux-worktree.sh open|open-pr|remove <repo-root> <branch-or-pr>" >&2
    exit 2
    ;;
esac
