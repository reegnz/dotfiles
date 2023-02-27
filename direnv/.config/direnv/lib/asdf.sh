#!/usr/bin/env bash

use_asdf() {
   ASDF_BIN="$(direnv_layout_dir)/asdf/bin"
   PATH_add "${ASDF_BIN}"
   if [[ -d "$ASDF_BIN" ]]; then
     return
   fi
   mkdir -p "${ASDF_BIN}"
   # gather all tools that have an effective version in the current directory
   asdf current 2>&1 | 
     awk '/______/{next}{print $1}' | 
     xargs -L1 asdf where | 
     awk '{print $0 "/bin"}' | 
     while read -r tool_bin; do
       for file in ${tool_bin}/*; do
           # softlink tool binaries into common bin directory
           ln -s "${file}" "${ASDF_BIN}"
       done
     done
}
