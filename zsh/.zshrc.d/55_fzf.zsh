if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --color=always'
elif (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files '
fi

export FZF_DEFAULT_OPTS="--ansi --height=50%"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"

#export FZF_ALT_C_COMMAND='fd --type d --color=always'

# integrate with `z`
#export FZF_ALT_C_COMMAND="_z 2>&1 | awk '{print \$2}' | tac"
export FZF_ALT_C_COMMAND="fzf-alt-c z"

#export FZF_ALT_C_OPTS="--preview 'exa --color=always --icons --group-directories-first --git -lah {}' --bind='alt-p:toggle-preview' --preview-window=~1"

FZF_ALT_C_OPTS="--preview-window=~1 --info=inline --keep-right"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --preview 'fzf-alt-c preview {}' --bind='alt-p:toggle-preview'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --disabled --prompt='z > '"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='change:reload(fzf-alt-c z {q} || true)'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-d:unbind(change)+change-prompt(fzf > )+enable-search+clear-query+reload(fzf-alt-c dirs)'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-z:rebind(change)+change-prompt(z > )+disable-search+clear-query+reload(fzf-alt-c z)'"
export FZF_ALT_C_OPTS
