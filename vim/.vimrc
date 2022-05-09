" Modeline and Notes {{{
" vim: set sw=2 ts=2 sts=2 tw=78 et foldlevel=0 foldmethod=marker :
" }}}

" Install vim plug {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup install
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif
" }}}

" Plugins {{{
call plug#begin('~/.vim/plugged')

" core: my must-have plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-speeddating'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', {'on': ['Files', 'GFiles', 'Buffers', 'Colors', 'Ag', 'Rg', 'Lines', 'BLines', 'Tags', 'BTags', 'Marks', 'Windows', 'Locate', 'History', 'Snippets', 'Commits', 'BCommits', 'Maps', 'Helptags', 'Filetypes'] }
Plug 'junegunn/vim-easy-align'

Plug 'flazz/vim-colorschemes'

Plug 'wincent/terminus'
Plug 'easymotion/vim-easymotion'
Plug 'mhinz/vim-signify'
Plug 'itchyny/lightline.vim'

Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle' }

Plug 'mhinz/vim-startify'

" dev: plugins to turn vim into my IDE
Plug 'dense-analysis/ale'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'hashivim/vim-terraform', { 'for': 'terraform' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown'}
" Plug 'jkramer/vim-checkbox'
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoUpdateBinaries' }
Plug 'buoto/gotests-vim', { 'for': 'go' }
Plug 'bfrg/vim-jq', { 'for': 'jq' }
Plug 'bhurlow/vim-parinfer', { 'for': 'clojure' }

" experimental: trying out new stuff
Plug 'thaerkh/vim-indentguides'

Plug 'mityu/vim-applescript', { 'for': 'applescript' }
" Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/switch.vim'
Plug 'direnv/direnv.vim'
Plug 'pbrisbin/vim-mkdir'
" Plug 'chrisbra/NrrwRgn'
Plug 'RRethy/vim-illuminate'
" Plug 'chr4/nginx.vim', { 'for': 'nginx' }

" Deoplete
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'

" has to be last place for startify
Plug 'ryanoasis/vim-devicons'

call plug#end()
"}}}

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

" split handling
"set splitbelow splitright

" Fix some colors {{{
"set fillchars+=vert:┆,fold:┄,
"highlight VertSplit cterm=NONE ctermfg=darkgrey ctermbg=NONE
"highlight EndOfBuffer ctermfg=darkgrey
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

" aws file types {{{
augroup filetypedetect
  au BufNewFile,BufRead ~/.aws/config*      set ft=dosini
  au BufNewFile,BufRead ~/.aws/credentials* set ft=dosini
augroup END
" }}}

" fix vimdiff colors {{{
" highlight DiffAdd    cterm=BOLD ctermfg=green  ctermbg=NONE
" highlight DiffDelete cterm=BOLD ctermfg=red    ctermbg=NONE
" highlight DiffChange cterm=BOLD ctermfg=yellow ctermbg=NONE
" highlight DiffText   cterm=BOLD ctermfg=black  ctermbg=yellow
" highlight SignColumn ctermbg=NONE
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

" :h restore-cursor {{{
augroup restore
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END
" }}}

" JIRA link handling like [ABC-123]: {{{
function OpenJira()
  let l:word = expand("<cWORD>")
  let l:match = matchlist(l:word, '\(\w\+-\d\+\)')
  if empty(l:match)
    return 0
  endif
  let l:issue = l:match[1]
  let l:url = g:jira_host . '/browse/' . l:issue
  call netrw#BrowseX(l:url, 0)
endfun

command OpenJira :call OpenJira()<CR>

nnoremap gj :call OpenJira()<CR>

let g:jira_host = 'https://jira.cloudera.com'

" }}}

" Search Google {{{
" see :h map-operator for how this is implemented
function BrowserSearch(a, b, c, type = '', ...)
  if a:type == ''
    set opfunc=BrowserSearch
    return 'g@'
  endif
  let sel_save = &selection
  let reg_save = getreginfo('"')
  let cb_save = &clipboard
  let visual_marks_save = [getpos("'<"), getpos("'>")]
  try
      set clipboard= selection=inclusive
	    let commands = #{line: "'[V']y", char: "`[v`]y", block: "`[\<c-v>`]y"}
      silent exe 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
      let text = getreg('"')
      let url = g:web_search_url .. text
      call netrw#BrowseX(url, 0)
  finally
    call setreg('"', reg_save)
    call setpos("'<", visual_marks_save[0])
    call setpos("'>", visual_marks_save[1])
    let &clipboard = cb_save
    let &selection = sel_save
  endtry

endfunction
nnoremap <expr> ss BrowserSearch()
xnoremap <expr> ss BrowserSearch()
let g:web_search_url = "https://google.com/search?q="
" }}}

" }}}

" Plugin configs {{{
" ==============

" preservim/nerdtree {{{
" ------------------
nnoremap <Leader><Tab> :NERDTreeToggle<CR>
" }}}

" dense-analysis/ale {{{
" ------------------
let g:ale_completion_enabled = 1
let b:ale_fix_on_save        = 1
let g:ale_fixers = {}
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']
let g:ale_fixers['js'] = ['prettier']
let g:ale_fixers['json'] = ['prettier', 'jq']
let g:ale_fixers['python'] = ['black', 'isort']
let g:ale_fixers['go'] = ['goimports', 'gofmt']
let g:ale_fixers['terraform'] = ['terraform']
let g:ale_fixers['md'] = ['remark_lint', 'markdownlint']
"let g:ale_fixers['sh'] = ['shfmt']
"let g:ale_fixers['bash'] = ['shfmt']

"let g:ale_linters_explicit = 1
"let g:ale_linters = {}
"let g:ale_linters['sh'] = ['shellcheck']
"let g:ale_linters['bash'] = ['shellcheck']
" }}}

" SirVer/UltiSnips {{{
" ----------------
"let g:UltiSnipsExpandTrigger       = "<Tab>"
"let g:UltiSnipsJumpForwardTrigger = "<Tab>"
"let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"
let g:UltiSnipsExpandTrigger       = "<C-right>"
let g:UltiSnipsJumpForwardTrigger = "<C-right>"
let g:UltiSnipsJumpBackwardTrigger = "<C-left>"

" }}}

" junegunn/vim-easy-align {{{
" -----------------------
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" itchyny/lightline.vim {{{
" ---------------------
set noshowmode
let g:lightline                       = {}
let g:lightline['active']             = {}
let g:lightline['component_function'] = {}

let g:lightline['active']['left']                   = [['mode', 'paste'], ['gitbranch', 'readonly', 'filename', 'modified']]
let g:lightline['component_function']['gitbranch']  = "FugitiveHead"
let g:lightline['component_function']['filetype']   = "MyFiletype"
let g:lightline['component_function']['fileformat'] = "MyFileformat"

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! MyFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

" }}}

" flazz/vim-colorschemes {{{
" ------------------------
set termguicolors
colorscheme gruvbox
" }}}

" }}}


set updatetime=1000
set autoread
augroup autoread_changes
  au BufEnter,FocusGained,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
  " au CursorMoved,CursorMovedI * checktime
augroup END
