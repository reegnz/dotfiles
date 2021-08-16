#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# pre-create some directories, so stow doesn't softlink
# the entire directory, just the contents
mkdir -p "$HOME/bin" "$HOME/.config/direnv/lib" "$HOME/.vim/UltiSnips" "$HOME/.config"

for dir in */; do
	stow -R -v --target "$HOME" "${dir%*/}"
done
