# check if asdf is installed
if (( ! ${+commands[asdf]} )); then
  return
fi
if [ -n "${ASDF_DIR:-}" ]; then
  return
fi
if [ ! -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]; then
  return
fi
. ${HOMEBREW_PREFIX}/opt/asdf/libexec/asdf.sh
export ASDFZF_VERSION_KEEP_kubectl="semver-no-prerelease"
