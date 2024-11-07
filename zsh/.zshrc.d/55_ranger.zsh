if [ ! -d ~/.config/ranger ]; then
  ranger --copy-config=all
fi
export RANGER_LOAD_DEFAULT_RC=false

if [ ! -d ~/.config/ranger/plugins/ranger_devicons ]; then
  git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
  # add line to ranger rc.conf if it doesn't exist yet
  file=~/.config/ranger/rc.conf
  chmod u+w $file
  option="default_linemode devicons"
  if ! grep -qF $option $file; then 
    echo "$option" >> $file
  fi
fi

alias ranger='source ranger'
alias r='ranger'
