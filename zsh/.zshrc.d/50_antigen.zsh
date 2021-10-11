# https://github.com/zsh-users/antigen
#
# Antigen is a package manager for zsh.
#
# Here I'm using my preferred configuration of zsh plugins.

antigen=/usr/local/share/antigen/antigen.zsh
if [ -f "$antigen" ]; then
	source "$antigen"

	# https://github.com/ohmyzsh/ohmyzsh
	antigen use oh-my-zsh

	# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
	antigen bundle sudo
	antigen bundle copybuffer
	antigen bundle fzf
	#antigen bundle colored-man-pages
	antigen bundle asdf
	#antigen bundle aws
	antigen bundle docker
	antigen bundle kubectl

	antigen bundle zdharma/fast-syntax-highlighting
	antigen theme romkatv/powerlevel10k
	antigen bundle reegnz/jq-zsh-plugin

	antigen apply
fi
