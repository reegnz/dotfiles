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

export FZF_ALT_C_OPTS="--preview 'fzf-alt-c preview {}' --bind='alt-p:toggle-preview' --bind='alt-a:reload:fzf-alt-c dirs' --bind='alt-z:reload:fzf-alt-c z' --preview-window=~1 --info=inline --keep-right"
