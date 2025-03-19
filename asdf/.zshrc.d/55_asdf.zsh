# check if asdf is installed
if (( ! ${+commands[asdf]} )); then
  return
fi
path=("$XDG_HOME/.asdf/shims" $path)
