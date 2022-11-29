if [ -n "$+commands[direnv]" ]; then
  direnv_cache=$ZSH_CACHE_DIR/direnv.zsh
  if [ ! -f $direnv_cache ]; then
    direnv hook zsh > $direnv_cache
  fi
  source $direnv_cache
  unset direnv_cache
fi
