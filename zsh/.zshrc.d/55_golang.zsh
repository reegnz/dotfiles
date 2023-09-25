if (( ! ${+commands[go]} )); then
  return
fi
export GOPATH="${XDG_HOME}/go"
path=($path "${GOPATH}/bin")
export GOPROXY="https://proxy.golang.org"
