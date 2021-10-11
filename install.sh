#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

for dir in */; do
	stow -R -v --no-folding --target "$HOME" "${dir%*/}"
done
