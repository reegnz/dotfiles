__daily_dir() {
  echo $XDG_HOME/daily/$(date +%F)
}

today() {
  local dir=$(__daily_dir)
  if [[ ! -d "$dir" ]]; then
    mkdir -p -- "$dir" || return
  fi
  builtin cd -- "$dir"
}

alias t=today
