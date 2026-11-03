#!/usr/bin/env bash
# git-window-label.sh <path> -> "<branch-icon> <branch> ⇡ahead ⇣behind !modified +staged ?untracked"
# Prints "default" outside a repo or on detached HEAD. Used as a tmux window name.
# --no-optional-locks: polling must not take the index lock from your own git commands.
set -uo pipefail

status=$(git -C "$1" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || {
  echo default
  exit 0
}

awk -v icon="" -v up="⇡" -v down="⇣" '
  /^# branch\.head/ { head = $3 }
  /^# branch\.ab/   { ahead = substr($3, 2); behind = substr($4, 2) }
  /^[12u] /         { if (substr($2, 1, 1) != ".") staged++
                      if (substr($2, 2, 1) != ".") modified++ }
  /^\?/             { untracked++ }
  END {
    if (head == "" || head == "(detached)") { print "default"; exit }
    out = icon " " head
    if (ahead  > 0) out = out " " up ahead
    if (behind > 0) out = out " " down behind
    if (modified)   out = out " !" modified
    if (staged)     out = out " +" staged
    if (untracked)  out = out " ?" untracked
    print out
  }' <<<"$status"
