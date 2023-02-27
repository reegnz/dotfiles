path=($path "${KREW_ROOT:-$XDG_HOME/.krew}/bin")


# kubectl() {
#   kubectl-speedup "$@"
# }



if [ -n "$+commands[pluto]" ]; then
  pluto_completion="$ZSH_CACHE_DIR/completions/_pluto"
  if [ ! -f "$pluto_completion" ]; then
    pluto completion zsh > "$pluto_completion"
  fi
  unset pluto_completiog
fi
