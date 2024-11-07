if (( ! ${+commands[cargo]} )); then
  return
fi
path=($path "${XDG_HOME}/.cargo/bin")
