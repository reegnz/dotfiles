# check if git is installed
if (( ! ${+commands[git]} )); then
  return
fi
cd_repo_root() {
	cd $(git repo-root)
}
