#shellcheck disable=SC2148

alias aws-edit-config='vim -c "cd ~/.aws" -c "Rg"'

aws-switch-profile() {
  if [[ $# -eq 0 ]]; then
    AWS_PROFILE="$(__aws_select_profile)"
    export AWS_PROFILE
    return
  fi

  while [[ $# -gt 0 ]]; do
    key="$1"
    case ${key} in
      -u|--unset)
        unset AWS_PROFILE
        echo "Unset AWS profile." >&2
        return
        ;;
      -c|--current)
        echo "${AWS_PROFILE}"
        return
        ;;
      -*)
        echo "Unknown flag: ${key}" >&2
        return 1
        ;;
      *)
        export AWS_PROFILE="${key}"
        return
        ;;
    esac
  done
}

_aws-switch-profile() {
    COMPREPLY=()
    local current=${COMP_WORDS[COMP_CWORD]}
    if [ "${COMP_CWORD}" -eq 2 ]; then
      return
    fi
    case ${current} in
      -*)
        flags="-u --unset -c --current"
        #shellcheck disable=SC2207
        COMPREPLY=( $(compgen -W "$flags" -- "${current}") )
        return
        ;;
      *)
        profiles=( $(aws-profiles) )
        COMPREPLY=( $( compgen -W "${profiles[*]}" -- "${current}" ) )
        return
        ;;
    esac
}
complete -F _aws-switch-profile aws-switch-profile

alias asp=aws-switch-profile
complete -F _aws-switch-profile asp

__aws_select_profile() (
    aws-profiles |
      fzf --reverse --preview "$(declare -f __aws_print_profile); __aws_print_profile {}"
)

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
      bat -l ini --color=always --decorations=never
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
