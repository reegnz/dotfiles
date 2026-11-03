root="${PWD}"
# ghq-style path under ~/repos (host/owner/repo) is unique; elsewhere fall back to parent/name.
if [[ "${root}" == "${HOME}/repos/"* ]]; then
  name="${root#"${HOME}/repos/"}"
else
  name="${PWD#"${PWD%/*/*}"/}"
fi
name="${name//./_}"
name="${name//:/_}"
name="${name//[[:space:]]/_}"
# tmux rejects "." in -t targets, so dots become "_": github.com/reegnz/dotfiles -> github_com/reegnz/dotfiles
# Still possible to clash outside ~/repos: disambiguate with a path hash.
if tmuxifier-tmux has-session -t "=${name}" 2>/dev/null; then
  name="${name}-$(printf %s "${root}" | cksum | cut -c1-6)"
fi
session_root "${root}"

if initialize_session "${name}"; then
  load_window "default"
fi
finalize_and_go_to_session
