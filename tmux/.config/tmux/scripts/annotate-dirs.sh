#!/usr/bin/env bash
# Reads dir paths on stdin (e.g. from zoxide) and prefixes each with a folder glyph
# tinted by state: green = has an active tmux session, grey = none. Order is left
# untouched. ANSI; the picker runs fzf with --ansi.
set -euo pipefail

# ---- constants --------------------------------------------------------------

DIR_GLYPH=''
GREEN=$'\e[32m'
GREY=$'\e[90m'
RESET=$'\e[0m'

# ---- helpers ----------------------------------------------------------------

# Paths that currently have a tmux session (empty if no server is running).
active_sessions() {
  tmux list-sessions -F '#{session_path}' 2>/dev/null || true
}

# Tint each stdin dir green if it has an active session, grey otherwise, keeping
# the input order.
annotate_dirs() {
  # First file = active session paths; the seeded=1 assignment flips once it's fully
  # read, so the dirs that follow are matched against the active-session set.
  awk -v glyph="$DIR_GLYPH" -v green="$GREEN" -v grey="$GREY" -v reset="$RESET" '
      !NF             { next }                                 # skip blank lines
      !seeded         { active[$0]; next }                     # file 1: vivify the key (bare ref creates it; value unused)
      !($0 in active) { print grey glyph reset " " $0; next }  # idle dir (common case): grey
                      { print green glyph reset " " $0 }       # fell through, so it is live: green
    ' <(active_sessions) seeded=1 -
}

# ---- main -------------------------------------------------------------------

annotate_dirs
