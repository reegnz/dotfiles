# check if eza is installed
if (( ! ${+commands[kubectl]} )); then
  return
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

