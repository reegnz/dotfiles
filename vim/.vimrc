if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup install
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif

call plug#begin('~/.vim/plugged')

" core: my must-have plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'wincent/terminus'

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'junegunn/fzf', { 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

Plug 'mhinz/vim-startify'

" dev: plugins to turn vim into my IDE
Plug 'dense-analysis/ale'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'editorconfig/editorconfig-vim'
Plug 'hashivim/vim-terraform'
"Plug 'sheerun/vim-polyglot'
Plug 'plasticboy/vim-markdown'
Plug 'jkramer/vim-checkbox'
Plug 'cespare/vim-toml'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'bfrg/vim-jq'
Plug 'Glench/Vim-Jinja2-Syntax'

" experimental: trying out new stuff
Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/switch.vim'
Plug 'direnv/direnv.vim'
Plug 'junegunn/vim-easy-align'
"Plug 'dhruvasagar/vim-table-mode'
Plug 'pbrisbin/vim-mkdir'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'chrisbra/NrrwRgn'
Plug 'RRethy/vim-illuminate'
Plug 'chr4/nginx.vim'
Plug 'bhurlow/vim-parinfer'

" Deoplete
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  if has('python3')
    Plug 'roxma/nvim-yarp', { 'do': 'pip3 install --user --upgrade pynvim'}
    Plug 'roxma/vim-hug-neovim-rpc'
  else
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif
endif
let g:deoplete#enable_at_startup = 1

call plug#end()



let g:jq_highlight_builtin_functions = 1
let g:jq_highlight_module_prefix     = 1
let g:jq_highlight_json_file_prefix  = 1
let g:jq_highlight_objects           = 1
let g:jq_highlight_function_calls    = 1

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

" convenience
nnoremap ; :

" split navigation
nnoremap <Leader>o       <c-w>o
nnoremap <Leader><up>    <c-w>k
nnoremap <Leader><down>  <c-w>j
nnoremap <Leader><left>  <c-w>h
nnoremap <Leader><right> <c-w>l

" scrolling
nnoremap <S-Down> <C-e>
nnoremap <S-Up>   <C-y>


augroup filetypedetect
  au BufNewFile,BufRead ~/.aws/config*      set ft=dosini
  au BufNewFile,BufRead ~/.aws/credentials* set ft=dosini
augroup END


" fix vimdiff colors
highlight DiffAdd    cterm=BOLD ctermfg=green  ctermbg=NONE
highlight DiffDelete cterm=BOLD ctermfg=red    ctermbg=NONE
highlight DiffChange cterm=BOLD ctermfg=yellow ctermbg=NONE
highlight DiffText   cterm=BOLD ctermfg=black  ctermbg=yellow


" Reload vimrc after saving
if !exists('*ReloadVimrc')
  fun! ReloadVimrc()
    source $MYVIMRC
  endfun
endif
autocmd! BufWritePost $MYVIMRC call ReloadVimrc()


" :h restore-cursor
augroup restore
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif
augroup END


" Daily note taking
" =================
function! s:open_daily_notes()
  let l:daily_note_template = $HOME . '/notes/daily/template.md'
  let l:daily_note = $HOME . '/notes/daily/' . strftime("%Y-%m-%d") . '.md'
  let l:new = 0
  if empty(expand(glob(l:daily_note)))
    let l:new = 1
  endif
  execute "edit " . l:daily_note
  if l:new
    execute "read " . l:daily_note_template
    execute "normal! ggddA " . strftime("%Y-%m-%d")
    execute "normal! o"
    execute "normal! G"
  endif
endfunction

command! Notes call s:open_daily_notes()


" Plugin configs
" ==============

" preservim/nerdtree
" ------------------
nnoremap <Leader><Tab> :NERDTreeToggle<CR>


" airblade/vim-gitgutter
" ----------------------
set updatetime=250
let g:gitgutter_max_signs = 500
" No mapping
let g:gitgutter_map_keys = 0
" Colors
let g:gitgutter_override_sign_column_highlight = 0
highlight clear SignColumn
highlight GitGutterAdd          ctermfg=2
highlight GitGutterChange       ctermfg=3
highlight GitGutterDelete       ctermfg=1
highlight GitGutterChangeDelete ctermfg=4


" dense-analysis/ale
" ------------------
let g:ale_completion_enabled = 1
let b:ale_fix_on_save        = 1
let g:ale_fixers = {
	\ '*': ['remove_trailing_lines', 'trim_whitespace'],
	\ 'js': ['prettier'],
	\ 'json': ['prettier', 'jq'],
	\ 'python': ['black', 'isort'],
	\ 'terraform': ['terraform'],
	\ 'md': ['remark_lint', 'markdownlint'],
	\ 'go': ['goimports', 'gofmt']
	\ }

  "\   'sh':        [ 'shfmt'],
  "\   'bash':      ['shfmt'],




" hashivim/vim-terraform
" ----------------------
let g:terraform_fmt_on_save = 0


" plasticboy/vim-markdown
" -----------------------
let g:vim_markdown_folding_disabled          = 1
let g:vim_markdown_frontmatter               = 1
let g:vim_markdown_strikethrough             = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:vim_markdown_autowrite                 = 1
let g:vim_markdown_follow_anchor             = 1
let g:vim_markdown_edit_url_in               = 'tab'
let g:vim_markdown_new_list_item_indent      = 0


" SirVer/UltiSnips
" ----------------
let g:UltiSnipsExpandTrigger       = "<tab>"
let g:UltiSnipsJumpForwardTrigger  = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<esc>[Z"
let g:UltiSnipsListSnippets        = "<esc>`"

"
" alok/notational-fzf-vim
" -----------------------
let g:nv_search_paths = [ '~/notes', '~/notes/daily' ]


" junegunn/vim-easy-align
" -----------------------
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)



" dhruvasagar/vim-table-mode
" --------------------------
function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
          \ <SID>isAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ <SID>isAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'


" AndrewRadev/switch.vim
" ----------------------
autocmd FileType gitrebase let b:switch_custom_definitions =
    \ [
    \   [ 'pick', 'reword', 'edit', 'squash', 'fixup', 'exec', 'drop' ]
    \ ]

autocmd FileType markdown let b:switch_custom_definitions =
    \ [
    \   {
    \      '\[\s\]\s\(.*\)': '[x] \1',
    \      '\[x\]\s\(.*\)': '[ ] \1'
    \   }
    \ ]
