# fix location of `pip3 install --user <package>`
export PYTHONUSERBASE="${XDG_HOME}/.local"
export PIPX_DEFAULT_PYTHON=python3

## pyenv
# if [ -n "$+commands[pyenv]" ]; then
#   export PYENV_ROOT="$XDG_HOME/.pyenv"
#   path=("${PYENV_ROOT}/shims" $path)
#   pyenv_cache=$ZSH_CACHE_DIR/pyenv.zsh
#   if [ ! -f $pyenv_cache ]; then
#     pyenv init - > $pyenv_cache
#     # https://github.com/pyenv/pyenv-virtualenv/issues/259#issuecomment-1007432346
#     pyenv virtualenv-init - | sed 's/precmd/precwd/g' >> $pyenv_cache
#     zcompile "$pyenv_cache"
#   fi
#   source $pyenv_cache
#   unset pyenv_cache
# fi

# if [ -n "$+commands[poetry]" ]; then
#   poetry_completion=$ZSH_CACHE_DIR/completions/_poetry
#   if [ ! -f "$poetry_completion" ]; then
#     poetry completions zsh > "$poetry_completion"
#   fi
#   unset poetry_completion
# fi

if [ -f "$HOME/.rye/env" ]; then
  source "$HOME/.rye/env"
fi
