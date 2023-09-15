if [ ! -f "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]; then
  return
fi
. ${HOMEBREW_PREFIX}/opt/asdf/libexec/asdf.sh
export ASDFZF_VERSION_KEEP_kubectl="semver-no-prerelease"
