# check if broot is installed
if (( ! ${+commands[broot]} )); then
  return
fi
broot_script=$HOME/.config/broot/launcher/bash/br
if [ ! -f $broot_script ]; then
  mkdir -p ${broot_script%/*}
  broot --print-shell-function zsh > $broot_script
  zcompile "$broot_script"
  broot --set-install-state=installed
fi
source $broot_script
unset broot_script
