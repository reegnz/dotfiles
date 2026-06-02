#!/usr/bin/env bash
# Reads dir paths from stdin, prefixes with 🟢 if an active tmux session
# exists for that path, 📁 otherwise.
if ! tmux ls &>/dev/null; then
  cat
fi
awk '
  NR==FNR { sessions[$0]=1; next }
  $0 in sessions { active[++na] = "🟢 " $0; next }
  { inactive[++ni] = "📁 " $0 }
  END { for (i=1;i<=na;i++) print active[i]; for (i=1;i<=ni;i++) print inactive[i] }
' <(tmux list-sessions -F '#{session_path}' 2>/dev/null) -
