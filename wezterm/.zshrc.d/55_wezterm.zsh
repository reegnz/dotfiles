if [[ -z "${WEZTERM_EXECUTABLE:-}" ]]; then
  return
fi
wezterm_shell_cache="${ZSH_CACHE_DIR}/wezterm.sh"
if [[ ! -s "$wezterm_shell_cache" ]]; then
  curl -o ${wezterm_shell_cache} https://raw.githubusercontent.com/wezterm/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh
  zcompile "${wezterm_shell_cache}"
fi
source "$wezterm_shell_cache"
unset wezterm_shell_cache
