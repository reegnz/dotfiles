#!/usr/bin/env bash
# pr-source.sh <repo-root>
# Source for the pull-request view in tmux-picker.sh.
set -eu
exec "$(dirname "$0")/annotate-prs.sh" "${1:?usage: pr-source.sh <repo-root>}"
