root="${PWD}"
name="${PWD#"${PWD%/*/*}"/}"
session_root "${root}"

if initialize_session "default/${name}"; then
  new_window
fi
finalize_and_go_to_session
