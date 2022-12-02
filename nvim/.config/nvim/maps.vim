" preservim/nerdtree {{{
" ------------------
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

" Moving visually selected text up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv


" Split management
" window
nmap <leader>sw<left>  :topleft vnew<cr>
nmap <leader>sw<right> :botright vnew<cr>
nmap <leader>sw<up>    :topleft new<cr>
nmap <leader>sw<down>  :botright new<cr>

" buffer
nmap <leader>s<left>   :leftabove vnew<cr>
nmap <leader>s<right>  :rightbelow vnew<cr>
nmap <leader>s<up>     :leftabove new<cr>
nmap <leader>s<down>   :rightbelow new<cr>
