# check if grc is installed
if (( ! ${+commands[grc]} )); then
  return
fi
for cmd in $( ls /opt/homebrew/opt/grc/share/grc/ ); do
  cmd="${cmd##*conf.}"
  if [ -n "$+commands[$cmd]" ]; then
    alias "${cmd}"="$commands[grc] --colour=auto ${cmd}"
  fi
done
