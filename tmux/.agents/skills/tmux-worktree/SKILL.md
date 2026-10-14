---
name: tmux-worktree
description: >-
  Use for requests to move work into a Git worktree, open a feature branch in
  tmux, or launch another AI agent. It integrates with this tmux setup instead
  of creating unmanaged worktrees or panes.
---

# Tmux worktrees and agents

Treat the tmux scripts as the worktree API. Do not replace them with raw
`git worktree add`, `tmux new-window`, or `tmux send-keys` commands for these
requests.

## Commands

The installed scripts are normally under `~/.config/tmux/scripts`:

```bash
tmux_dir="${TMUX_CONFIG_DIR:-$HOME/.config/tmux}"
worktree_tool="${TMUX_WORKTREE_SCRIPT:-$tmux_dir/scripts/tmux-worktree.sh}"
agent_tool="${TMUX_AGENT_SCRIPT:-$tmux_dir/scripts/tmux-agent.sh}"
```

`tmux-worktree.sh` creates or opens the worktree, creates the corresponding
`ai` window, and focuses it:

```bash
"$worktree_tool" open "$root" "$branch"
```

`tmux-agent.sh` does the same setup and starts an agent in the worktree's
existing window. Pass the agent executable and its arguments after `--`:

```bash
"$agent_tool" launch "$root" "$branch" -- claude
"$agent_tool" launch "$root" "$branch" -- pi
"$agent_tool" launch "$root" "$branch" -- claude "Implement the requested feature"
```

Use the executable the user requested or the executable already being used.
Do not assume that `claude`, `pi`, and `cursor` accept the same prompt or
resume flags. A newly launched agent needs a self-contained handoff brief; it
does not automatically inherit this conversation.

Both commands must be run from inside tmux (`$TMUX` must be set). If tmux is
not available, report that the operation cannot be completed through this
integration rather than silently falling back to an unmanaged worktree or
pane.

## Resolve the repository and branch

Use the repository's **main checkout** as `root`, even when the current agent
is already in a worktree. This resolves the shared Git directory:

```bash
common_git_dir="$(git rev-parse --git-common-dir)"
root="$(cd "$(dirname "$(cd "$common_git_dir" && pwd)")" && pwd)"
```

If this is not a Git repository, stop and tell the user. If the user did not
specify a branch, derive a short conventional name such as
`feat/search-filter` only when the request is unambiguous; otherwise ask for a
branch name. Validate it with:

```bash
git -C "$root" check-ref-format --branch "$branch"
```

Do not reuse the current branch for a new agent unless the user explicitly
asks for that. The script supports slash-separated names such as
`feat/search-filter` and places them below `$root/.worktrees/`.

## Move existing work

Opening a new worktree starts it from the current commit. It does **not** move
uncommitted changes. When the user means “move my current edits”, preserve
them explicitly before opening the worktree:

```bash
if [[ -n "$(git -C "$root" status --porcelain)" ]]; then
  git -C "$root" stash push -u -m "tmux move: $branch"
  "${worktree_tool}" open "$root" "$branch"
  worktree="$(git -C "$root" for-each-ref \
    --format='%(worktreepath)' "refs/heads/$branch")"
  git -C "$worktree" stash pop
else
  "${worktree_tool}" open "$root" "$branch"
fi
```

`-u` includes untracked files; ignored files are not included. If stash
application conflicts, stop and report the conflict instead of continuing in
the old checkout. Do not claim that the current agent moved: its process and
working directory remain where they started. To continue the work in the new
worktree, launch a replacement agent there with `agent_tool` and a concise
handoff, then stop changing files in the old checkout.

## Launching a parallel agent

For “launch another agent to develop X”:

1. Resolve `root` and choose/confirm a dedicated branch.
2. Run `agent_tool launch ...`; never launch it in the current pane.
3. Give it a self-contained task, constraints, and validation instructions.
4. Tell the user the branch/worktree path and tmux window. The helper refuses
   to overwrite a pane already running an agent. Only set
   `TMUX_AGENT_FORCE=1` when the user explicitly asks to replace that agent.

Example:

```bash
"$agent_tool" launch "$root" "feat/search-filter" -- claude \
  "Implement the search-filter feature. Run the relevant tests and leave the changes in this worktree."
```

## Cleanup and verification

Only remove a worktree when the user asks. Use the integration so its window
and branch are handled together:

```bash
"$worktree_tool" remove "$root" "$branch"
```

The remove action prompts before dropping dirty or unmerged work. Verify
locations with `git -C "$root" worktree list`; do not infer success merely
from the command returning after a non-tmux no-op.
