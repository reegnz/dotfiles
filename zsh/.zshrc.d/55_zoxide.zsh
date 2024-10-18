# check if fzf is installed
if (( ! ${+commands[zoxide]} )); then
  return
fi
zoxide_hook_cache="${ZSH_CACHE_DIR}/zoxide.zsh"
if [[ "$commands[zoxide]" -nt "$zoxide_hook_cache" || ! -s "$zoxide_hook_cache" ]]; then
  zoxide init zsh >| "$zoxide_hook_cache"
fi
source "$zoxide_hook_cache"
unset zoxide_hook_cache
