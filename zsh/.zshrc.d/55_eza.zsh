# check if eza is installed
if (( ! ${+commands[eza]} )); then
  return
fi

alias x='eza --icons --group-directories-first'
alias xl='x -lah'
alias ls='x'
alias ll='xl'
alias l='ll'

function chpwd_eza() {
	if [ -z "${ENABLE_CHPWD_EZA:-}" ]; then
		return
	fi
	eza -1 --icons --group-directories-first
}
function toggle_chpwd_eza() {
	if [ -n "${ENABLE_CHPWD_EZA:-}" ]; then
		unset ENABLE_CHPWD_EZA
		return
	fi
	export ENABLE_CHPWD_EZA=1
}
chpwd_functions=(${chpwd_functions[@]} "chpwd_eza")

# export ENABLE_CHPWD_EZA=1
