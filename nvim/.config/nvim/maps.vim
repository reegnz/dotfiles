" preservim/nerdtree {{{
" ------------------
lua <<EOF
EOF
nnoremap <Leader><Tab> <cmd>NvimTreeToggle<CR>
" }}}

" junegunn/vim-easy-align {{{
" -----------------------
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" split navigation {{{
nnoremap <Leader>o       <c-w>o
nnoremap <Leader><up>    <c-w>k
nnoremap <Leader><down>  <c-w>j
nnoremap <Leader><left>  <c-w>h
nnoremap <Leader><right> <c-w>l
" }}}

" better code indenting {{{
" indent move
vnoremap > >gv
vnoremap < <gv
" }}}

nnoremap ; :

" Increment / Decrement
nnoremap == <C-a>
nnoremap -- <C-x>


" LSPSaga
" nnoremap <silent> <leader>ca <cmd>Lspsaga code_action<CR>
" vnoremap <silent> <leader>ca <cmd><C-U>Lspsaga range_code_action<CR>
" nnoremap <silent> <leader>cd <cmd>Lspsaga show_line_diagnostics<CR>

" nnoremap <silent> K <cmd>Lspsaga hover_doc<CR>
" nnoremap <silent> gh <cmd>Lspsaga lsp_finder<CR>
" nnoremap <silent> gr <cmd>Lspsaga rename<CR>
" nnoremap <silent> gs <cmd>Lspsaga signature_help<CR>
" nnoremap <silent> gd <cmd>Lspsaga preview_definition<CR>

" nnoremap <silent> [e <cmd>Lspsaga diagnostic_jump_next<CR>
" nnoremap <silent> ]e <cmd>Lspsaga diagnostic_jump_prev<CR>

