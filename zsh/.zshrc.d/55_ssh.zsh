if [ "$platform" = "darwin" ]; then
    # use macos keychain to add ssh keys
    ssh-add --apple-use-keychain &>/dev/null
fi
