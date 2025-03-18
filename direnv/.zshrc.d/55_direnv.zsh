# check if direnv is installed
if (( ! ${+commands[direnv]} )); then
  return
fi

_direnv_hook() {
  trap -- '' SIGINT
  eval "$("/opt/homebrew/bin/direnv" export zsh)"
  trap - SIGINT
}

direnv_hook_disable() {
  typeset -ag precmd_functions
  if (( ${precmd_functions[(I)_direnv_hook]} )); then
    precmd_functions=(${precmd_functions:#_direnv_hook})
  fi
  typeset -ag chpwd_functions
  if (( ${chpwd_functions[(I)_direnv_hook]} )); then
    chpwd_functions=(${chpwd_functions#_direnv_hook})
  fi
}

direnv_hook_enable() {
  typeset -ag precmd_functions
  if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
    precmd_functions=(_direnv_hook $precmd_functions)
  fi
  typeset -ag chpwd_functions
  if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
    chpwd_functions=(_direnv_hook $chpwd_functions)
  fi
}

direnv_hook_toggle() {
  typeset -ag precmd_functions
  if (( ${precmd_functions[(I)_direnv_hook]} )); then
    direnv_hook_disable
  else
    direnv_hook_enable
  fi
}

direnv_hook_enable
