#!/usr/bin/env bash
# tmux file picker — fd + fzf + bat preview, pastes selected path into the pane.
set -uo pipefail

dir="${1:-$(tmux display-message -p '#{pane_current_path}')}"

if command -v bat >/dev/null; then
  preview='bat --color=always --style=numbers {}'
else
  preview='cat {}'
fi

selected=$(
  fd --follow --hidden --type f --color=always . "$dir" \
    | fzf --ansi --tmux 90% --layout=reverse --info=inline \
        --prompt 'files > ' \
        --preview "$preview" \
        --bind 'alt-p:toggle-preview' \
        --bind 'tab:down,btab:up' \
        --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-f:page-down,ctrl-b:page-up'
) || exit 0

[ -z "$selected" ] && exit 0

# Make path relative to pane dir when it's a descendant, otherwise keep absolute.
rel="${selected#"$dir"/}"
[ "$rel" = "$selected" ] && rel="$selected"

tmux send-keys "$rel"
