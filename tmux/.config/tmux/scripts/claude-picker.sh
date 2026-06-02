#!/bin/bash
pane=$(tmux list-panes -a \
  -F '#{?@is_claude,#{@claude_status_icon} #{@claude_status} #{session_name}:#{window_index}.#{pane_index} #{pane_title},}' \
  | grep -v '^$' \
  | fzf --no-sort)

[ -z "$pane" ] && exit 0

target=$(echo "$pane" | awk '{print $3}')
tmux switch-client -t "$target"
