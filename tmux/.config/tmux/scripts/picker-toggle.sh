#!/usr/bin/env bash
# picker-toggle.sh <repo-root>
# fzf transform: switch the second picker stage between branches and PRs.
set -eu
root="${1:?usage: picker-toggle.sh <repo-root>}"
here="$(dirname "$0")"
case "${FZF_PROMPT:-}" in
  prs*)
    printf 'change-prompt(branches(local) > )+reload(%q %q)' \
      "$here/branch-source.sh" "$root"
    ;;
  *)
    printf 'change-prompt(prs > )+reload(%q %q)' \
      "$here/pr-source.sh" "$root"
    ;;
esac
