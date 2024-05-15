# check if direnv is installed
if (( ! ${+commands[direnv]} )); then
  return
fi
direnv_hook_cache="${ZSH_CACHE_DIR}/direnv.zsh"
if [[ "$commands[direnv]" -nt "$direnv_hook_cache" || ! -s "$direnv_hook_cache" ]]; then
  direnv hook zsh >| "$direnv_hook_cache"
  zcompile "$direnv_hook_cache"
fi
if [ -z "${DIRENV_DISABLE:-}" ]; then
  source "$direnv_hook_cache"
fi
unset direnv_hook_cache

