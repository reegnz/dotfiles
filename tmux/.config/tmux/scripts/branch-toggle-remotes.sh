#!/usr/bin/env bash
# branch-toggle-remotes.sh <repo-root>
# fzf transform: flip the branch list between local and local+remote by changing
# the prompt, then reload — branch-source.sh reads the new prompt for the mode.
# Reads $FZF_PROMPT (exported by fzf for transform bindings) for the current mode.
set -eu
src="$(dirname "$0")/branch-source.sh"
root="$1"

case "${FZF_PROMPT:-}" in
  *local+remote*)
    printf 'change-prompt(branches(local) > )+reload(%s %q)' "$src" "$root" ;;
  *)
    printf 'change-prompt(branches(local+remote) > )+reload(%s %q)' "$src" "$root" ;;
esac
