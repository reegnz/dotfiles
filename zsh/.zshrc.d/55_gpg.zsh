if [[ -t 1 ]]; then
  export GPG_TTY=$(tty)
fi
