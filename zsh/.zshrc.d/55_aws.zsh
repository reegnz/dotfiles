export AWS_STS_REGIONAL_ENDPOINTS=regional
export PREVIEW_AWS_PROFILE_THEME=${PREVIEW_AWS_PROFILE_THEME:-gruvbox-dark}

_fzf_complete_asp() {
  _fzf_complete \
    --preview "$(declare -f __aws_print_profile); __aws_print_profile {}" \
    -- "$@" < <( aws-profiles )
}

__aws_print_profile() (
  local profile=$1
  local pattern="\\\[(profile )?${profile}]"
  awk -v pattern="${pattern}" '
    $0 ~ pattern {
      keep = 1
      print
      next
    }
    /\[.*]/ {
      keep = 0;
    }
    keep' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" |
    if type bat &>/dev/null; then
      bat -l ini --color=always --decorations=never --theme=${PREVIEW_AWS_PROFILE_THEME}
    else
      cat
    fi
  )

aws-profiles() (
  local file="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  if [ ! -f "${file}" ]; then
    return
  fi
  awk -F'[][ ]' \
    '/\[profile .*]/{print $3;next}; /\[.*]/{print $2;next}' \
    "${file}"
)

alias gimme-aws-creds="AWS_DEFAULT_REGION=eu-central-1 gimme-aws-creds"
alias awsp='asp $(aws-profiles | fzf --reverse --preview "$(declare -f __aws_print_profile); __aws_print_profile {}")'
alias aws-edit-config='vim -c "cd ~/.aws" -c "Rg"' # open fzf ripgrep vim plugin in the aws config folder
alias ac='aws-edit-config'
