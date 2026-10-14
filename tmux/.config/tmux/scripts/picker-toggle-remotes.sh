#!/usr/bin/env bash
# picker-toggle-remotes.sh <repo-root>
# Keep ctrl-r's branch remote toggle harmless while the PR view is active.
set -eu
root="${1:?usage: picker-toggle-remotes.sh <repo-root>}"
here="$(dirname "$0")"
case "${FZF_PROMPT:-}" in
  prs*) exit 0 ;;
  *) exec "$here/branch-toggle-remotes.sh" "$root" ;;
esac
