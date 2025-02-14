if (( $+commands[terraform] )); then
  alias tf=terraform
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C terraform terraform
fi

if (( $+commands[consul] )); then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C consul consul
fi


if (( ! $+commands[tfenv] )); then
  return
fi

tfenv_switch_arch() {
  if [ -n "$TFENV_ARCH" ]; then
    echo "tfenv: switching to native" >&2
    unset TFENV_ARCH TFENV_CONFIG_DIR
    return
  fi
  echo "tfenv: switching to amd64" >&2
  export TFENV_ARCH=amd64
  export TFENV_CONFIG_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/tfenv/${TFENV_ARCH}
}
