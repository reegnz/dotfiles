export FZF_DEFAULT_COMMAND='fd --type f --color=always'
export FZF_DEFAULT_OPTS="--ansi --height=50%"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"

export FZF_ALT_C_COMMAND='fd --type d --color=always'
export FZF_ALT_C_OPTS="--preview 'exa --color=always --icons --group-directories-first --git -lah {}' --bind='alt-p:toggle-preview' --preview-window=~1"
