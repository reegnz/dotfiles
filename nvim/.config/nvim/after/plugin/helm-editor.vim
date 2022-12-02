function HelmDevEnv()
  let helmcmd = "while sleep 0.1; do fd | entr -c -d sh -c 'helm template --name-template my ./ -f values.testing.yaml | bat -l yaml'; done"
  call termopen(helmcmd)
  vsplit templates/deployment.yaml
  split values.testing.yaml
  vsplit values.yaml
endfun


command! HelmTemplate call HelmDevEnv()<CR>
