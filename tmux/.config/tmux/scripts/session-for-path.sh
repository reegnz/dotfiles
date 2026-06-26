#!/usr/bin/env bash
# session-for-path.sh <path>
# Print the tmux session name whose working dir is <path> (nothing if none).
tmux list-sessions -F '#{session_path}|#{session_name}' 2>/dev/null \
  | awk -F'|' -v p="$1" '$1 == p { print $2; exit }'
