#!/usr/bin/env bash
# dir-source.sh — the directory list sources behind the tmux picker.
#
#   dir-source.sh list <zoxide|dirs|repos> [query]
#       Print the annotated directory list for one source (one path per line).
#   dir-source.sh cycle
#       Print the fzf actions to rotate to the next source.
#   dir-source.sh reload
#       Print the fzf action to re-list the current source.
#
# cycle/reload read $FZF_PROMPT (fzf exports it to transform bindings) to learn
# the current source. Sources rotate zoxide -> dirs -> repos -> zoxide: zoxide is
# query-driven (fzf forwards its query), dirs/repos use fzf's own fuzzy search.
set -eu

here="$(cd "$(dirname "$0")" && pwd)"
self="$here/$(basename "$0")"
annotate="$here/annotate-dirs.sh"

current_source() {
  case "${FZF_PROMPT:-zoxide}" in
    dirs*)  echo dirs ;;
    repos*) echo repos ;;
    *)      echo zoxide ;;
  esac
}

case "${1:?usage: dir-source.sh list|cycle|reload}" in
  list)
    case "${2:?usage: dir-source.sh list <source> [query]}" in
      zoxide) zoxide query --list -- ${3:-} ;;
      dirs)   fd --follow --hidden --type d --color=always ;;
      repos)  ghq list -p ;;
    esac | "$annotate"
    ;;
  cycle)
    case "$(current_source)" in
      zoxide) printf 'enable-search+unbind(change)+clear-query+change-prompt(dirs > )+reload(%s list dirs)'     "$self" ;;
      dirs)   printf 'enable-search+clear-query+change-prompt(repos > )+reload(%s list repos)'                  "$self" ;;
      repos)  printf 'disable-search+rebind(change)+clear-query+change-prompt(zoxide > )+reload(%s list zoxide)' "$self" ;;
    esac
    ;;
  reload)
    printf 'reload(%s list %s)' "$self" "$(current_source)"
    ;;
esac
