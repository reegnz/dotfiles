#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

OS=$(uname)
echo "Detected OS: $OS" >&2
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
	echo "Installing ${dirname}" >&2
	stow -R -v --no-folding --target "$HOME" "${dir%*/}"
done
