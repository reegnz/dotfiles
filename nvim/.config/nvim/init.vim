" Modeline and Notes {{{
" vim: set sw=2 ts=2 sts=2 tw=78 et foldlevel=0 foldmethod=marker :
" }}}

runtime ./plug.vim
runtime ./maps.vim

" Plugin configs {{{
" ==============

set termguicolors
colorscheme gruvbox

" General {{{
set nowrap
set nofoldenable
set conceallevel=2
set hidden
set noswapfile
"set autochdir
" allow cross-talk between yank buffer and system clipboard
set clipboard=unnamed
" for incrementing alphabetic numbers with  <C-A> and <C-X>
set nrformats+=alpha

" improve search
set ignorecase
set smartcase

set showbreak=↪\ 
set listchars=tab:→\ ,eol:↲,nbsp:␣,space:•,trail:•,extends:⟩,precedes:⟨

set undodir=~/.local/share/nvim/undodir
set undofile

set nu rnu

" AWS {{{
augroup awsfiletype
  au BufNewFile,BufRead ~/.aws/config*      set ft=dosini
  au BufNewFile,BufRead ~/.aws/credentials* set ft=dosini
augroup END
" }}}

" Reload vimrc after saving {{{
if !exists('*ReloadVimrc')
  fun! ReloadVimrc()
    source $MYVIMRC
  endfun
endif
autocmd! BufWritePost $MYVIMRC call ReloadVimrc()
command VimRC :edit $MYVIMRC
" }}}

" restore-cursor {{{
" See :h restore-cursor for details
augroup restore
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END
" }}}

"}}}
"
set completeopt=menu,menuone,noselect



set updatetime=1000
set autoread
augroup autoread_changes
  au BufEnter,FocusGained,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
  " au CursorMoved,CursorMovedI * checktime
augroup END

" highlight recently yanked selection
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=1000}
augroup END

augroup toggle_relative
    au InsertEnter * silent! set nornu
    au InsertLeave * silent! set rnu
augroup END


command! Scratch new | setlocal noswapfile | setlocal buftype=nofile | setlocal bufhidden=hide

command! -range=% Jq <line1>,<line2>y z <bar> Scratch <bar> 0put=@z

let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'
