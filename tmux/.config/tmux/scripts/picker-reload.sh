#!/usr/bin/env bash
# picker-reload.sh <repo-root>
# Emit the reload action for whichever branch/PR view fzf currently shows.
set -eu
root="${1:?usage: picker-reload.sh <repo-root>}"
here="$(dirname "$0")"
case "${FZF_PROMPT:-}" in
  prs*) source="$here/pr-source.sh" ;;
  *)     source="$here/branch-source.sh" ;;
esac
printf 'reload(%q %q)' "$source" "$root"
