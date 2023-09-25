# check if eza is installed
if (( ! ${+commands[eza]} )); then
  return
fi

alias x='eza --icons --group-directories-first --git'
alias xl='x -lah'
alias ls='x'
alias ll='xl'
alias l='ll'

function chpwd_exa() {
	if [ -z "${ENABLE_CHPWD_EXA:-}" ]; then
		return
	fi
	exa -1 --icons --group-directories-first
}
function toggle_chpwd_exa() {
	if [ -n "${ENABLE_CHPWD_EXA:-}" ]; then
		unset ENABLE_CHPWD_EXA
		return
	fi
	export ENABLE_CHPWD_EXA=1
}
chpwd_functions=(${chpwd_functions[@]} "chpwd_exa")

export ENABLE_CHPWD_EXA=1
