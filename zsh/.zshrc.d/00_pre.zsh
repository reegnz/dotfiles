unamestr="$(uname)"
case "$unamestr" in
	"Linux")
		platform="${unamestr:l}"
		;;
	"Darwin")
		platform="${unamestr:l}"
		;;
	*)
		platform="unknown"
		;;
esac


export XDG_HOME="${XDG_HOME:-${HOME}}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${XDG_HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_DATA_HOME:-${XDG_HOME}/.local/state}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${XDG_HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${XDG_HOME}/.cache}"

ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
fpath+="$ZSH_CACHE_DIR/completions"

if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}/completions"
fi

# Figure out the SHORT hostname
if [[ $platform == "darwin" ]]; then
  short_host_cache="$ZSH_CACHE_DIR/shorthost.cache"
  if [[ ! -f "$short_host_cache" ]]; then
    # OS X
    if (( $+commands[scutil] )); then
      SHORT_HOST=$(scutil --get ComputerName)
      SHORT_HOST="${SHORT_HOST%% \(*\)}"
      SHORT_HOST="${SHORT_HOST// /-}"
      SHORT_HOST="${SHORT_HOST//’/}"
      SHORT_HOST="${SHORT_HOST:l}"
    else
      SHORT_HOST=${HOST/.*/}
    fi
    printf '%s\n' "$SHORT_HOST" >| "$short_host_cache"
  fi
  IFS= read -r SHORT_HOST < "$short_host_cache"
  export SHORT_HOST
  unset short_host_cache
fi

# Save the location of the current completion dump file.
# Forces oh-my-zsh to use this location.
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
# I swear OMZ just keeps adding crap to annoy me.
ZSH_DISABLE_COMPFIX=true
