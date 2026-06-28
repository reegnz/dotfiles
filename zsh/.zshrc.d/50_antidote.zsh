mac_antidote=/opt/homebrew/opt/antidote/share/antidote/antidote.zsh
linux_antidote=/usr/share/zsh-antidote/antidote.zsh
if [ -f "$mac_antidote" ]; then
  antidote=$mac_antidote
elif [ -f "$linux_antidote" ]; then
  antidote=$linux_antidote
fi

setopt extended_glob

export ANTIDOTE_HOME="${XDG_CACHE_HOME}/antidote"

source $antidote
source <(antidote init)

antidote bundle <<EOF
getantidote/use-omz
ohmyzsh/ohmyzsh path:lib
ohmyzsh/ohmyzsh path:plugins/iterm2
ohmyzsh/ohmyzsh path:plugins/sudo
ohmyzsh/ohmyzsh path:plugins/copybuffer
ohmyzsh/ohmyzsh path:plugins/aws

romkatv/powerlevel10k
reegnz/jq-zsh-plugin
zdharma-continuum/fast-syntax-highlighting
zsh-users/zsh-completions path:src kind:fpath
zsh-users/zsh-autosuggestions
EOF
