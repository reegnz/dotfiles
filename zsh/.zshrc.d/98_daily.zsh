__daily_dir() {
  echo $HOME/daily/$(date --iso-8601=date)
}

today() {
  if [ ! -d $(__daily_dir) ]; then
    mkdir -p $(__daily_dir)
  fi
  cd $(__daily_dir)
}

alias t=today
