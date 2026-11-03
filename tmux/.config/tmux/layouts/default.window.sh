# Branch icon only for a named branch; detached HEAD or non-repo gets a plain name.
if wname=$(git -C "$PWD" symbolic-ref --quiet --short HEAD 2>/dev/null); then
  wname=" $wname"
else
  wname=default
fi
window_root "${PWD}"
new_window "$wname"

# Emulate a per-window root: tmux only tracks a session cwd, so stash this window's
# worktree path as a window-scoped user option. Split/new-window bindings read it
# (see @window_root in tmux.conf). || true: layouts run under tmuxifier's set -e.
tmuxifier-tmux set-option -w -t "$session:$window" @window_root "$PWD" || true

#split_h 50
#split_v 30
# run_cmd "claude --continue" 1
# run_cmd 'y' 2
# select_pane 1
