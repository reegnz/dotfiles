# check if fzf is installed
if (( ! ${+commands[fzf]} )); then
  return
fi

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --follow --type f --color=always'
elif (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg -follow --files'
fi
export FZF_DEFAULT_OPTS="--ansi --height=50%"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"

FZF_ALT_C_OPTS="--preview-window=25%,~1 --info=inline --keep-right --bind='alt-p:toggle-preview'"
if (( ${+commands[eza]} )); then
  EZA_COMMAND='eza -1 --icons --group-directories-first --color=always'
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --preview '$EZA_COMMAND {}'"
else
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --preview 'ls -lah {}'"
fi
# check if zoxide is installed
if (( ${+commands[zoxide]} )); then
  # integrate with zoxide
  ZOXIDE_COMMAND='zoxide query -l'
  PWD_FILTER='sed -n -e "s,^$PWD/,," -e "/^[^\/]/p"'
  export FZF_ALT_C_COMMAND="$ZOXIDE_COMMAND | $PWD_FILTER"
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --disabled --prompt='z > '"
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='change:reload(echo {q} | xargs zoxide query -l | $PWD_FILTER)'"
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-d:unbind(change)+change-prompt(dirs > )+enable-search+clear-query+reload(fd --type d --color=always)'"
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-z:rebind(change)+change-prompt(z > )+disable-search+clear-query+reload($ZOXIDE_COMMAND | $PWD_FILTER)'"
  FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-f:unbind(change)+change-prompt(z-fzf > )+enable-search+clear-query'"
fi

export FZF_ALT_C_OPTS
