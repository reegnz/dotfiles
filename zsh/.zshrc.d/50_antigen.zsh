# https://github.com/zsh-users/antigen
#
# Antigen is a package manager for zsh.
#
# Here I'm using my preferred configuration of zsh plugins.

export ANTIGEN_LOG=$XDG_CACHE_HOME/antigen.log

mac_antigen="${HOMEBREW_PREFIX}/share/antigen/antigen.zsh"
linux_antigen="/usr/share/zsh/share/antigen.zsh"
if [ -f "$mac_antigen" ]; then
  antigen="$mac_antigen"
elif [ -f "$linux_antigen" ]; then
  antigen="$linux_antigen"
else
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
antigen bundle kubectl
antigen bundle aws

# 3rd party plugins and themes
antigen theme romkatv/powerlevel10k
antigen bundle reegnz/jq-zsh-plugin

antigen bundle zdharma-continuum/fast-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen apply
