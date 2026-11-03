# Window name is the git label (branch + status); tmux refreshes it via automatic-rename-format.
wname=$("$HOME/.config/tmux/scripts/git-window-label.sh" "$PWD")
window_root "${PWD}"
new_window "$wname"

# Emulate a per-window root: tmux only tracks a session cwd, so stash this window's
# worktree path as a window-scoped user option. Split/new-window bindings read it
# (see @window_root in tmux.conf). || true: layouts run under tmuxifier's set -e.
tmuxifier-tmux set-option -w -t "$session:$window" @window_root "$PWD" || true
# new-window -n turns automatic-rename off; re-enable so the label keeps updating.
tmuxifier-tmux set-option -w -t "$session:$window" automatic-rename on || true

#split_h 50
#split_v 30
# run_cmd "claude --continue" 1
# run_cmd 'y' 2
# select_pane 1
