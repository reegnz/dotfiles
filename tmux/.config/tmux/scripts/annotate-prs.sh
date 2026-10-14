#!/usr/bin/env bash
# annotate-prs.sh <repo-root>
# Print open GitHub pull requests for the picker. Field 2 is always the PR
# number so fzf can pass it to tmux-worktree.sh without parsing the display text.
# PR worktrees use the private local branch name pr/<number>.
set -euo pipefail
root="${1:?usage: annotate-prs.sh <repo-root>}"

PR_GLYPH='' # nf-oct-pull-request
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
GREY=$'\e[90m'
RESET=$'\e[0m'

command -v gh >/dev/null 2>&1 || exit 0

# A pane starts in its worktree, so this is enough to tell whether the PR has a
# visible tmux window. The path is kept as the lookup key, including spaces.
windows() {
  tmux list-windows -a -F '#{pane_current_path}' 2>/dev/null || true
}

# PR worktrees are deliberately named pr/<number>, keeping them separate from
# a local checkout of the PR's head branch (which may also be in the picker).
pr_worktrees() {
  git -C "$root" worktree list --porcelain 2>/dev/null | awk '
    /^worktree / { path = substr($0, 10) }
    /^branch refs\/heads\/pr\// {
      number = substr($0, length("branch refs/heads/pr/") + 1)
      print number "\t" path
      path = ""
    }
  '
}

pull_requests() {
  (
    cd "$root"
    gh pr list --state open --limit 100 \
      --json number,title,headRefName,baseRefName,isDraft,author \
      --jq '.[] | [.number, .title, .headRefName, .baseRefName, (if .isDraft then "draft" else "open" end), (.author.login // "")] | @tsv'
  ) 2>/dev/null || true
}

# Input files are labelled so empty worktree/window streams do not affect the
# state carried by awk. Display columns after the number are intentionally
# informational; {2} remains the stable PR number for the picker actions.
awk -F '\t' -v glyph="$PR_GLYPH" \
  -v green="$GREEN" -v yellow="$YELLOW" -v grey="$GREY" -v reset="$RESET" '
    function emit(colour, number, title, head, base, state, author) {
      details = title "  " head " → " base "  " state
      if (author != "") details = details "  @" author
      print colour glyph reset " " number " " details
    }

    kind == "window" { window[$0]; next }
    kind == "worktree" { worktree[$1] = $2; next }
    kind == "pr" {
      path = worktree[$1]
      if (path == "")              emit(grey,   $1, $2, $3, $4, $5, $6)
      else if (path in window)      emit(green,  $1, $2, $3, $4, $5, $6)
      else                          emit(yellow, $1, $2, $3, $4, $5, $6)
      next
    }
  ' \
  kind=window <(windows) \
  kind=worktree <(pr_worktrees) \
  kind=pr <(pull_requests)
