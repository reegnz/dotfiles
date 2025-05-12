# check if eza is installed
if (( ! ${+commands[kubectl]} )); then
  return
fi

if (( ${+commands[kubecolor]} )); then
  kubecolor_completion=$ZSH_CACHE_DIR/completions/_kubecolor
  if [ ! -f "$kubecolor_completion" ]; then
    {
      echo "#compdef kubecolor\ncompdef _kubectl kubecolor"
      cat $ZSH_CACHE_DIR/completions/_kubectl
    } > $kubecolor_completion
  fi
  unset kubecolor_completion
  alias kubectl=kubecolor
fi

alias k=kubectl

if [ -n "$+commands[pluto]" ]; then
  pluto_completion="$ZSH_CACHE_DIR/completions/_pluto"
  if [ ! -f "$pluto_completion" ]; then
    pluto completion zsh > "$pluto_completion"
  fi
  unset pluto_completion
fi

if (( ! ${+commands[kubectl-krew]} )); then
  return
fi
path=($path "${KREW_ROOT:-$XDG_HOME/.krew}/bin")

