#!/usr/bin/env bash
# kill-session-for-path.sh <dir>
# Kill the tmux session whose working dir is <dir>, if one exists.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
name=$("$here/session-for-path.sh" "$1")
if [ -n "$name" ]; then
  tmux kill-session -t "$name"
fi
