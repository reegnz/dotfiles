# check if git is installed
if (( ! ${+commands[git]} )); then
  return
fi
alias cd-git-repo-root=git repo-root

cd-git-worktree() {
  local dir
  dir=$(fzf --reverse \
    --bind 'start:reload(git worktree list)' \
    --bind 'enter:become(echo {1})' \
    --preview 'git -C {1} status --short 2>/dev/null; echo "---"; git -C {1} log --oneline -8 2>/dev/null' \
    --preview-window 'right:40%')
  if [ -n "$dir" ]; then
    cd "${dir}"
  fi
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


if [[ -o zle ]]; then
  git-switch-branch() {
  if branch=$(git branch --sort=-committerdate -vvv --color=always | awk '/\*/{next};1' | fzf --reverse --prompt="branch > " --bind 'enter:become(echo {1})'); then
      LBUFFER="git switch ${branch}"
    fi
    zle reset-prompt
  }

  zle -N git-switch-branch
  # bind `alt + j` to jq-complete
  bindkey '\es' git-switch-branch
fi
