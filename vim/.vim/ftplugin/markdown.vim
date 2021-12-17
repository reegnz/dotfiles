" plasticboy/vim-markdown {{{
" -----------------------
let g:vim_markdown_folding_disabled          = 1
let g:vim_markdown_frontmatter               = 1
let g:vim_markdown_strikethrough             = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:vim_markdown_autowrite                 = 1
let g:vim_markdown_follow_anchor             = 1
let g:vim_markdown_edit_url_in               = 'tab'
let g:vim_markdown_new_list_item_indent      = 0
" }}}

" AndrewRadev/switch.vim {{{
" ----------------------
let b:switch_custom_definitions =
    \ [
    \   {
    \      '\[\s\]\s\(.*\)': '[x] \1',
    \      '\[x\]\s\(.*\)': '[ ] \1'
    \   }
    \ ]
" }}}
