iterm_script_path="$HOME/.cache/iterm2_shell_integration.zsh"
if [ ! -f "$iterm_script_path" ]; then
	echo "Downloading iterm shell integration..."
	curl -# -L https://iterm2.com/shell_integration/zsh \
		-o "$iterm_script_path"
fi
source "$iterm_script_path"
unset iterm_script_path
