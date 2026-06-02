#!/usr/bin/env bash
# fzf + zoxide → tmuxifier session launcher
# 🟢 = dir already has an active tmux session  📁 = zoxide only

# Capture client before any popups open (display-message has no client in run-shell)
TMUX_CLIENT=$(tmux list-clients -t "${TMUX_PANE:-}" -F '#{client_name}' 2>/dev/null | head -1)

# ── Step 1: annotated dir picker ─────────────────────────────────────────────
ANNOTATE="$HOME/.config/tmux/scripts/annotate-dirs.sh"

ZOXIDE_COMMAND="zoxide query -l | ${ANNOTATE}"
GHQ_COMMAND='ghq list -p'

zoxide_start="echo \"rebind(change)+change-prompt(zoxide > )+disable-search+clear-query+reload($ZOXIDE_COMMAND)\""
dirs_start="echo \"unbind(change)+change-prompt(dirs > )+enable-search+clear-query+reload(fd --follow --hidden --type d --color=always)\""
repos_start="echo \"rebind(change)+change-prompt(repos > )+enable-search+clear-query+reload($GHQ_COMMAND)\""

if command -v eza &>/dev/null; then
  preview_cmd='eza -1 --icons --group-directories-first --color=always'
else
  preview_cmd='ls -lah'
fi

transform_change="
  case \$FZF_PROMPT in
    zoxide*)
      echo \"reload(echo {q} | xargs $ZOXIDE_COMMAND)\"
      ;;
  esac"

change_mode="
  case \$FZF_PROMPT in
    zoxide*)
      echo 'enable-search+unbind(change)+clear-query+change-prompt(dirs  )+reload(fd --follow --hidden --type d --color=always)'
      ;;
    dirs*)
      echo 'enable-search+clear-query+change-prompt(repos  )+reload(ghq list -p)'
      ;;
    repos*|fzf*)
      echo 'disable-search+rebind(change)+clear-query+change-prompt(zoxide  )+reload($ZOXIDE_COMMAND)'
      ;;
  esac"

# Kill the tmux session whose path matches the selected item (🟢 only)
delete_session='p=$(echo {} | cut -d" " -f2-); s=$(tmux list-sessions -F "#{session_path}|#{session_name}" 2>/dev/null | awk -F"|" -v x="$p" '"'"'$1==x{print $2; exit}'"'"'); [ -n "$s" ] && tmux kill-session -t "$s"'

reload_after_delete="
  case \$FZF_PROMPT in
    zoxide*) echo \"reload($ZOXIDE_COMMAND)\" ;;
    dirs*)   echo \"reload(fd --follow --hidden --type d --color=always)\" ;;
    repos*)  echo \"reload($GHQ_COMMAND)\" ;;
  esac"

selection=$(
  # zoxide query -l | "$ANNOTATE" |
  fzf \
    --ansi --disabled --tmux \
    --bind "start:transform:$zoxide_start" \
    --bind "change:transform:$transform_change" \
    --bind "alt-c:transform:$change_mode" \
    --bind 'ctrl-d:half-page-down' \
    --bind 'ctrl-u:half-page-up' \
    --bind 'ctrl-f:page-down' \
    --bind 'ctrl-b:page-up' \
    --header 'alt-c: mode  alt-d: delete-session' \
    --bind 'tab:down,btab:up' \
    --bind "change:reload(echo {q} | xargs zoxide query -l | $ANNOTATE)" \
    --preview "${preview_cmd} $(echo {} | cut -d' ' -f2-)" \
    --preview-window '25%,~1' \
    --info=inline \
    --keep-right \
    --bind 'alt-p:toggle-preview' \
    --bind "alt-d:execute-silent($delete_session)+transform:$reload_after_delete"
)

[[ -z "$selection" ]] && exit 0
selection="${selection#* }" # strip emoji prefix

# ── Output or execute depending on context ───────────────────────────────────
if [[ -n "$TMUX" ]]; then
  cd "$selection" && unset TMUXIFIER_SESSION_ROOT && tmuxifier load-session ai
  session=$(tmux list-sessions -F '#{session_path}|#{session_name}' 2>/dev/null |
    awk -F'|' -v p="$selection" '$1==p {print $2; exit}')
  [[ -n "$session" ]] && tmux switch-client -t "$session"
else
  printf '%s\n' "$selection"
fi
