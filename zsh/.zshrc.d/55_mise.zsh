# check if mise is installed
if (( ! ${+commands[mise]} )); then
  return
fi
mise_hook_cache="${ZSH_CACHE_DIR}/mise.zsh"
if [[ "$commands[mise]" -nt "$mise_hook_cache" || ! -s "$mise_hook_cache" ]]; then
  mise activate zsh >| "$mise_hook_cache"
  zcompile "$mise_hook_cache"
fi
source "$mise_hook_cache"
unset mise_hook_cache
