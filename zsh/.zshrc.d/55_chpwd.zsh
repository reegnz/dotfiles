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
