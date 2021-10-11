function asp() {
  if [[ -z "$1" ]]; then
    AWS_PROFILE="$(aws_select_profile)"
    export AWS_PROFILE
  fi

  if [[ "$1" = "-u" ]]; then
    unset AWS_PROFILE
    echo "Unset AWS profile."
    return
  fi
}

alias aws_edit_config='vim -c "cd ~/.aws" -c "Rg"'

function aws_select_profile() {
    aws_profiles |
      fzf --reverse \
        --preview 'awk '"'"'/\[(profile )?{}]/{keep=1;print;next};/\[.*]/{keep=0};keep{print}'"'"' "${AWS_CONFIG_FILE:-$HOME/.aws/config}"|bat -l ini --color=always -p'
}

function aws_profiles() {
  awk -F'[][ ]' \
    '/\[profile .*]/{print $3;next}; /\[.*]/{print $2;next}' \
    "${AWS_CONFIG_FILE:-$HOME/.aws/config}"
}
