if [ "$platform" = "darwin" ]; then
    # use macos keychain to add ssh keys
    ssh-add -K &>/dev/null
fi
