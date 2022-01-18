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


XDG_HOME="${XDG_HOME:-${HOME}}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${XDG_HOME}/.local/share}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${XDG_HOME}/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${XDG_HOME}/.cache}"

ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"

if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

# Figure out the SHORT hostname
if [ -n "$commands[scutil]" ]; then
  # OS X
  SHORT_HOST=$(scutil --get ComputerName)
  SHORT_HOST="${SHORT_HOST%% \(*\)}"
  SHORT_HOST="${SHORT_HOST// /-}"
  SHORT_HOST="${SHORT_HOST//’/}"
  SHORT_HOST="${SHORT_HOST:l}"
else
  SHORT_HOST=${HOST/.*/}
fi
export SHORT_HOST

# Save the location of the current completion dump file.
# Forces oh-my-zsh to use this location.
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
# I swear OMZ just keeps adding crap to annoy me.
ZSH_DISABLE_COMPFIX=true
