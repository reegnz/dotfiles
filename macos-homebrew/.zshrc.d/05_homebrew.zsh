if [ -n "${HOMEBREW_PREFIX:-}" ]; then
  return
fi
homebrew_cache="$ZSH_CACHE_DIR/homebrew.sh"

if [ ! -f "{$homebrew_cache}" ]; then
  /opt/homebrew/bin/brew shellenv >| $homebrew_cache
  /opt/homebrew/bin/brew command-not-found-init >> $homebrew_cache
fi
source $homebrew_cache
unset homebrew_cache
