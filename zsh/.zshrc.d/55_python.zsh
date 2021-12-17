# fix location of `pip3 install --user <package>`
export PYTHONUSERBASE=$HOME/.local

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
pathmunge "$PYENV_ROOT/shims" before
export PATH
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
fi

export PIPX_DEFAULT_PYTHON=python3
