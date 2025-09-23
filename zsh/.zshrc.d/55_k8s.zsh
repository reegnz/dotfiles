# check if eza is installed
if (( ${+commands[kubectl]} )); then
  alias k=kubectl
fi

if (( ${+commands[kubecolor]} )); then
  kubecolor_completion=$ZSH_CACHE_DIR/completions/_kubecolor
  if [ ! -f "$kubecolor_completion" ]; then
    echo "#compdef kubecolor\ncompdef _kubectl kubecolor" >| $kubecolor_completion
  fi
  unset kubecolor_completion
  alias kubectl=kubecolor
fi

if ((  "${+commands[kubectl-krew]}" )); then
  path=($path "${KREW_ROOT:-$XDG_HOME/.krew}/bin")
fi
