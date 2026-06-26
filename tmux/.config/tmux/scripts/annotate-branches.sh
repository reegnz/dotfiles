#!/usr/bin/env bash
# annotate-branches.sh <repo-root> [local|all]
# Prints branches for fzf (--ansi), each tagged with a colour-coded branch glyph:
#   green  local, has a window      yellow local, worktree but no window
#   grey   local, branch only       magenta remote-only (all mode)
# Local branches that track an upstream get a p10k-style suffix:
#   ⇡N commits to push   ⇣N commits to pull   = in sync   gone upstream deleted
# (no suffix => the branch has no upstream at all). The branch name stays the
# second field so the picker's {2} still extracts it cleanly.
# "all" appends remote branches that have no local counterpart, by short name;
# picking one makes tmux-worktree.sh create a local tracking branch.
set -euo pipefail
root="$1"
mode="${2:-local}"

# ---- constants --------------------------------------------------------------

BRANCH_GLYPH='' # nf-fa-code_branch (U+F126)
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
GREY=$'\e[90m'
MAGENTA=$'\e[35m'
RED=$'\e[31m'
RESET=$'\e[0m'

# ---- facts (one stream per awk input file) ----------------------------------

# Paths with a window open, across all sessions.
windows() { tmux list-windows -a -F '#{pane_current_path}' 2>/dev/null || true; }
# Local branches, sorted, tab-separated:
#   "<branch><TAB><worktree-path><TAB><upstream-short><TAB><ahead/behind>"
# worktree-path & upstream-short are empty when absent; the track field is git's
# "ahead N, behind M" / "gone" / "" (empty == tracked and in sync).
locals() { git -C "$root" for-each-ref --sort=refname \
  --format='%(refname:short)%09%(worktreepath)%09%(upstream:short)%09%(upstream:track,nobracket)' refs/heads; }
# Remote branch short names, sorted (lstrip drops "refs/remotes/<remote>/"; only in "all" mode).
remotes() {
  [[ "$mode" == all ]] || return 0
  git -C "$root" for-each-ref --sort=refname --format='%(refname:lstrip=3)' refs/remotes
}

# ---- classify + colour ------------------------------------------------------

# Each input file is labelled by a kind=... assignment, evaluated between files
# (so it works even when a file is empty). Windows seed the lookup set before
# locals are classified; remotes come last, after the local set is complete.
awk -F '\t' -v glyph="$BRANCH_GLYPH" \
  -v green="$GREEN" -v yellow="$YELLOW" -v grey="$GREY" -v magenta="$MAGENTA" -v red="$RED" -v reset="$RESET" '
    function emit(colour, branch) { print colour glyph reset " " branch }

    # p10k-style upstream suffix from for-each-refs %(upstream:short)/%(upstream:track).
    # Returns "" for an untracked branch so the name is emitted bare. Colours its own
    # arrows and starts with a space, so it tacks onto the branch as later fields.
    function trackinfo(up, track,   ahead, behind, s) {
      if (up == "")        return ""                       # no upstream
      if (track == "gone") return " " red "gone" reset     # upstream deleted
      ahead = behind = 0
      if (match(track, /ahead [0-9]+/))  ahead  = substr(track, RSTART + 6, RLENGTH - 6)
      if (match(track, /behind [0-9]+/)) behind = substr(track, RSTART + 7, RLENGTH - 7)
      s = ""
      if (ahead  + 0 > 0) s = s " " green "⇡" ahead reset    # commits to push
      if (behind + 0 > 0) s = s " " red   "⇣" behind reset   # commits to pull
      return (s == "") ? " " grey "=" reset : s             # tracked & in sync
    }

    kind == "window" { window[$0]; next }            # vivify: a window sits at this path
    kind == "local"  { local[$1]                     # vivify: remember the local name
                       sfx = trackinfo($3, $4)
                       if ($2 == "")          emit(grey,   $1 sfx)   # no worktree
                       else if ($2 in window) emit(green,  $1 sfx)   # worktree + window
                       else                   emit(yellow, $1 sfx)   # worktree, no window
                       next }
    kind == "remote" { if ($1 == "HEAD") next                 # the origin/HEAD pointer
                       if ($1 in local || $1 in seen) next     # already a local branch / another remote
                       seen[$1]
                       emit(magenta, $1) }
  ' \
  kind=window <(windows) \
  kind=local <(locals) \
  kind=remote <(remotes)
