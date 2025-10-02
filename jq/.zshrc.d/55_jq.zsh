_gojq-yaml-complete() {
  export JQ_REPL_JQ=gojq
  export JQ_REPL_ARGS="--yaml-input --yaml-output"
  export JQ_PATHS_ARGS="--yaml-input --yaml-output"
  jq-complete
  unset JQ_REPL_JQ JQ_REPL_ARGS JQ_PATHS_ARGS
}

zle -N _gojq-yaml-complete
# bind alt + y to _gojq-yaml-complete
bindkey '\ey' _gojq-yaml-complete
