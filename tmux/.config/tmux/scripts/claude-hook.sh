#!/bin/bash
[ -z "$TMUX_PANE" ] && exit 0

case "$1" in
  thinking) icon="🧠" ;;
  idle) icon="✨" ;;
  feedback) icon="❓" ;;
  "")
    tmux set-option -p -u -t "$TMUX_PANE" @claude_status 2>/dev/null
    tmux set-option -p -u -t "$TMUX_PANE" @claude_status_icon 2>/dev/null
    tmux set-option -p -u -t "$TMUX_PANE" @is_claude 2>/dev/null
    exit 0 ;;
  *) icon="" ;;
esac

tmux set-option -p -t "$TMUX_PANE" @claude_status "$1"
tmux set-option -p -t "$TMUX_PANE" @claude_status_icon "$icon"
tmux set-option -p -t "$TMUX_PANE" @is_claude 1
