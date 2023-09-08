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


export KREW_ROOT="${XDG_DATA_HOME}/krew"

krew_link() {
  for file in $KREW_ROOT/bin/*; do
    ln -f -s $file $(realpath --relative-to "${HOME}/.local/bin" -s $file) "${HOME}/.local/bin"
  done
}
