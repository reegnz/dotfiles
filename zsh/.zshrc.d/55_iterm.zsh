# only load if terminal emulator is iTerm2
if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
	iterm_script_path="$ZSH_CACHE_DIR/iterm2_shell_integration.zsh"
	if [ ! -f "$iterm_script_path" ]; then
		echo "Downloading iterm shell integration..."
		curl -# -L https://iterm2.com/shell_integration/zsh \
			-o "$iterm_script_path"
	fi
	source "$iterm_script_path"
	unset iterm_script_path
fi
