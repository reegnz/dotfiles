root="${PWD}"
name="${PWD#"${PWD%/*/*}"/}"
name="${name//./_}"
name="${name//:/_}"
name="${name//[[:space:]]/_}"
session_root "${root}"

if initialize_session "${name}"; then
  load_window "ai"
fi
finalize_and_go_to_session
