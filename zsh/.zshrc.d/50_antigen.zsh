# https://github.com/zsh-users/antigen
#
# Antigen is a package manager for zsh.
#
# Here I'm using my preferred configuration of zsh plugins.

export ANTIGEN_LOG=$HOME/antigen.log

antigen=/usr/local/share/antigen/antigen.zsh
if [ -f "$antigen" ]; then
	source "$antigen"

	# https://github.com/ohmyzsh/ohmyzsh
	antigen use oh-my-zsh
	# oh-my-zsh builtin plugins
	antigen bundle iterm2
	antigen bundle sudo
	antigen bundle copybuffer
	antigen bundle fzf
	antigen bundle aws
	antigen bundle kubectl
	antigen bundle z

	# 3rd party plugins and themes
	antigen theme romkatv/powerlevel10k
	antigen bundle reegnz/jq-zsh-plugin

	antigen bundle zdharma-continuum/fast-syntax-highlighting
	antigen bundle zsh-users/zsh-autosuggestions
	antigen apply
fi
