#!/usr/bin/env bash
# branch-source.sh <repo-root>
# Print the annotated branch list for the picker. Mode comes from $FZF_PROMPT
# (fzf exports it): "local+remote" includes remotes; anything else — including the
# empty default at startup — is local only.
set -eu
case "${FZF_PROMPT:-}" in
  *local+remote*) mode=all ;;
  *)              mode=local ;;   # default, incl. empty startup prompt
esac
exec "$(dirname "$0")/annotate-branches.sh" "${1:?usage: branch-source.sh <repo-root>}" "$mode"
