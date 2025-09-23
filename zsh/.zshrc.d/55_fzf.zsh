# check if fzf is installed
if (( ! ${+commands[fzf]} )); then
  return
fi
fzf_hook_cache="${ZSH_CACHE_DIR}/fzf.zsh"
if [[ "$commands[fzf]" -nt "$fzf_hook_cache" || ! -s "$fzf_hook_cache" ]]; then
  fzf --zsh >| "$fzf_hook_cache"
  zcompile "$fzf_hook_cache"
fi
source "$fzf_hook_cache"
unset fzf_hook_cache
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
if (( ! ${+commands[zoxide]} )); then
  export FZF_ALT_C_OPTS
  return
fi

# integrate with zoxide
ZOXIDE_COMMAND='zoxide query -l'
GHQ_COMMAND='ghq list -p'
PWD_FILTER='sed -n -e \"s,^$PWD/,,\" -e \"/^[^\/]/p\"'

zoxide_start="echo \"rebind(change)+change-prompt(zoxide > )+disable-search+clear-query+reload($ZOXIDE_COMMAND | $PWD_FILTER)\""

transform_change="
  case \$FZF_PROMPT in
    zoxide*)
      echo \"reload(echo {q} | xargs $ZOXIDE_COMMAND | $PWD_FILTER)\"
      ;;
  esac"

change_mode="
  case \$FZF_PROMPT in
    zoxide*)
      echo \"unbind(change)+change-prompt(dirs > )+enable-search+clear-query+reload(fd --follow --type d --color=always)\"
      ;;
    dirs*)
      echo \"rebind(change)+change-prompt(repos > )+enable-search+clear-query+reload($GHQ_COMMAND)\"
      ;;
    repos*)
      echo \"rebind(change)+change-prompt(zoxide > )+disable-search+clear-query+reload($ZOXIDE_COMMAND | $PWD_FILTER)\"
      ;;
  esac"

FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --disabled"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='start:transform:$zoxide_start'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='change:transform:$transform_change'"
FZF_ALT_C_OPTS="$FZF_ALT_C_OPTS --bind='alt-c:transform:$change_mode'"

export FZF_ALT_C_OPTS
