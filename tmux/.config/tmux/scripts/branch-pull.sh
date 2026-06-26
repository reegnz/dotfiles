#!/usr/bin/env bash
# branch-pull.sh <repo-root> <branch>
# Fast-forward <branch> from its upstream, non-destructively (never forced):
#   checked out somewhere  -> pull --ff-only in that worktree (updates its tree too)
#   not checked out        -> update the ref directly via a fetch refspec
# git refuses to fetch into a checked-out branch, hence the split. Driven by the
# branch picker's ctrl-p bind.
set -eu
root="$1"
branch="$2"

# Where this branch is checked out (empty if nowhere) and what it tracks.
worktree=$(git -C "$root" for-each-ref --format='%(worktreepath)' "refs/heads/$branch")
upstream=$(git -C "$root" for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
if [ -z "$upstream" ]; then
  echo "'$branch' has no upstream" >&2
  exit 1
fi

if [ -n "$worktree" ]; then
  git -C "$worktree" pull --ff-only
else
  # "<remote>/<remote-branch>" -> remote + ref. The refspec rejects a non-ff update.
  git -C "$root" fetch "${upstream%%/*}" "${upstream#*/}:$branch"
fi
