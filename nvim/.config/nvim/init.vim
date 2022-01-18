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
set autochdir
" allow cross-talk between yank buffer and system clipboard
set clipboard=unnamed
" for incrementing alphabetic numbers with  <C-A> and <C-X>
set nrformats+=alpha

" improve search
set ignorecase
set smartcase

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

