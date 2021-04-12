# dotfiles

These are my dotfiles to bootstrap my shell environments.
I'm using GNU stow to install these configs.

## git

```sh
stow git
```

Using the configs:
You need to set up a ~/.gitconfig that's not under version control:

```ini
[include]
  path = .gitconfig-common
  path = .gitconfig-macos

[includeIf "gitdir:~/private"]
  path = ".gitconfig-private"

[includeIf "gitdir:~/work"]
  path = ".gitconfig-work"
```
