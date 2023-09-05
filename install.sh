#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

install() {
	OS=$(uname)
	for dir in */; do
		dir="${dir%/*}"
		dirname="${dir##*/}"
		# skip OS specific stuff if OS does not match
		if [[ "${dirname}" == "macos" ]] && [[ $OS != "Darwin" ]]; then
			echo "Skipping ${dirname}" >&2
			continue
		fi
		if [[ "${dirname}" == "linux" ]] && [[ $OS != "Linux" ]]; then
			echo "Skipping ${dirname}" >&2
			continue
		fi
		# blacklisting packages
		case $dirname in
		"nvim-legacy")
			echo "Skipping $dirname" >&2
			continue
			;;
		esac
		echo "Installing ${dirname}" >&2
		stow -R -v --no-folding --target "$HOME" "${dir%*/}"
	done
}

add_color() {
	awk '
    BEGIN{
      bold="\033[1m"
      underline="\033[4m"
      red="\033[31m"
      green="\033[32m"
      yellow="\033[33m"
      blue="\033[34m"
      magenta="\033[35m"
      clear="\033[0m"
    }
    /^Installing/{
      print green bold underline $0 clear
      next
    }
    /^Skipping/{
      print yellow bold underline $0 clear
      next
    }

    /^UNLINK:/{
      first=$1
      $1=""
      print yellow first clear $0
      next
    }
    /^LINK:/{
      first=$1
      $1=""
      print green first clear $0
      next
    }
    /^BUG/{
      print red $0 clear
      next
    }
    1'
}

# See https://github.com/aspiers/stow/issues/65#issuecomment-1465060710
strip_bug() {
	awk '/^BUG in find_stowed_path\? Absolute\/relative mismatch/{next};1'
}

install 2> >(strip_bug | add_color)
