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
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${XDG_HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${XDG_HOME}/.cache}"

ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
fpath+="$ZSH_CACHE_DIR/completions"

if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}/completions"
fi

# Figure out the SHORT hostname
if [ ! -f $ZSH_CACHE_DIR/shorthost.sh ]; then
  # OS X
  if [ -n "$+commands[scutil]" ]; then
    SHORT_HOST=$(scutil --get ComputerName)
    SHORT_HOST="${SHORT_HOST%% \(*\)}"
    SHORT_HOST="${SHORT_HOST// /-}"
    SHORT_HOST="${SHORT_HOST//’/}"
    SHORT_HOST="${SHORT_HOST:l}"
  else
    SHORT_HOST=${HOST/.*/}
  fi
  echo "export SHORT_HOST=$SHORT_HOST"  > $ZSH_CACHE_DIR/shorthost.sh
fi
source $ZSH_CACHE_DIR/shorthost.sh

# Save the location of the current completion dump file.
# Forces oh-my-zsh to use this location.
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
# I swear OMZ just keeps adding crap to annoy me.
ZSH_DISABLE_COMPFIX=true

autoload -U bashcompinit && bashcompinit
autoload -Uz compinit && compinit
