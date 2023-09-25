if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --color=always'
elif (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files'
fi
export FZF_DEFAULT_OPTS="--ansi --height=50%"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"


# integrate with zoxide
ZOXIDE_COMMAND='zoxide query -l'
EXA_COMMAND='exa -1 --icons --group-directories-first --color=always'
PWD_FILTER='sed -n -e "s,^$PWD/,," -e "/^[^\/]/p"'
export FZF_ALT_C_COMMAND="$ZOXIDE_COMMAND | $PWD_FILTER"

FZF_ALT_C_OPTS="--preview-window=25%,~1 --info=inline --keep-right"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --preview '$EXA_COMMAND {}' --bind='alt-p:toggle-preview'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --disabled --prompt='z > '"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='change:reload(echo {q} | xargs zoxide query -l | $PWD_FILTER)'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-d:unbind(change)+change-prompt(dirs > )+enable-search+clear-query+reload(fd --type d --color=always)'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-z:rebind(change)+change-prompt(z > )+disable-search+clear-query+reload($ZOXIDE_COMMAND | $PWD_FILTER)'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-f:unbind(change)+change-prompt(z-fzf > )+enable-search+clear-query'"

export FZF_ALT_C_OPTS
