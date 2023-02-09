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

" set showbreak=↪\
set listchars=tab:>\ ,trail:-,space:-,nbsp:+

set undodir=~/.local/share/nvim/undodir
set undofile

set nu rnu
"}}}

set completeopt=menu,menuone,noselect

let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

let g:sneak#label = 1


if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat^=%f:%l:%c:%m
endif
nnoremap <Leader>g :silent grep<Space>


" command! -range=% Base64URLDecode <line1>,<line2>c<c-r>=system('basenc --base64url -d', @")<cr><esc>
" command! -range=% Base64URLEncode c<c-r>=system('basenc --base64url', @")<cr><esc>
" command! -range=% Base64Decode c<c-r>=system('basenc --base64 -d', @")<cr><esc>
" command! -range=% Base64Encode c<c-r>=system('basenc --base64', @")<cr><esc>
