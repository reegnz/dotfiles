if (( ! $+commands[tmux] )); then
  return
fi

path=($path "$XDG_HOME/.config/tmux/plugins/tmuxifier/bin")
export TMUXIFIER_LAYOUT_PATH="$HOME/.config/tmux/layouts"

# ts(): tmuxifier session/project picker (fzf + zoxide)
ts() {
  if [[ -n "$TMUX" ]]; then
    ~/.config/tmux/scripts/tmux-picker.sh
  else
    local output dir layout
    output=$(~/.config/tmux/scripts/tmux-picker.sh) || return 0
    [[ -z "$output" ]] && return 0
    dir=${output%%$'\n'*}
    [[ -n "$dir" ]] || return 0
    cd "$dir" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session ai
  fi
}

# Ctrl+F: open the picker from the shell prompt
_ts_zle() { ts; zle reset-prompt }
zle -N _ts_zle
bindkey '^F' _ts_zle
