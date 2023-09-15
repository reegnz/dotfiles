# https://github.com/zsh-users/antigen
#
# Antigen is a package manager for zsh.
#
# Here I'm using my preferred configuration of zsh plugins.

export ANTIGEN_LOG=$XDG_CACHE_HOME/antigen.log

antigen="${HOMEBREW_PREFIX}/share/antigen/antigen.zsh"
if [ ! -f "$antigen" ]; then
  antigen="/usr/share/zsh/share/antigen.zsh"
fi
if [ ! -f "$antigen" ]; then
  return
fi
source "$antigen"

# https://github.com/ohmyzsh/ohmyzsh
antigen use oh-my-zsh
# oh-my-zsh builtin plugins
antigen bundle iterm2
antigen bundle sudo
antigen bundle copybuffer
antigen bundle command-not-found
antigen bundle fzf
antigen bundle kubectl
antigen bundle zoxide
antigen bundle aws

# 3rd party plugins and themes
antigen theme romkatv/powerlevel10k
antigen bundle reegnz/jq-zsh-plugin

antigen bundle zdharma-continuum/fast-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen apply
