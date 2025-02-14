# check if git is installed
if (( ! ${+commands[git]} )); then
  return
fi
cd_repo_root() {
	cd $(git repo-root)
}

if (( ! ${+commands[git-town]})); then
  return
fi

git_town_cache="${ZSH_CACHE_DIR}/git-town.zsh"
if [[ "$commands[git-town]" -nt "$git_town_cache" || ! -s "$git_town_cache" ]]; then
  git town completions zsh >| "$git_town_cache"
  zcompile "$git_town_cache"
fi
# source "$git_town_cache"
unset git_town_cache 
