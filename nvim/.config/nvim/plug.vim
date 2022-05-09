" Modeline and Notes {{{
" vim: set sw=2 ts=2 sts=2 tw=78 et foldlevel=0 foldmethod=marker :
" }}}

" Install vim plug {{{
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
  silent !curl -fLo stdpath('data') ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
       \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  augroup install
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif
" }}}

" Plugins {{{
call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dadbod' | Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'tpope/vim-speeddating'


Plug 'wincent/terminus'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/vim-easy-align'


Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'nvim-lualine/lualine.nvim'

" Rice
Plug 'flazz/vim-colorschemes'
Plug 'mhinz/vim-startify'
Plug 'RRethy/vim-illuminate'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'folke/lsp-colors.nvim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'mhinz/vim-signify'


" NERDTree integrations
Plug 'kyazdani42/nvim-tree.lua'
Plug 'preservim/nerdtree',                      { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin',             { 'on': 'NERDTreeToggle' }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle' }
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'

" FZF
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': [ 'Files', 'GFiles', 'Buffers', 'Colors', 'Ag', 'Rg', 'Lines', 'BLines', 'Tags', 'BTags', 'Marks', 'Windows', 'Locate', 'History', 'Snippets', 'Commits', 'BCommits', 'Maps', 'Helptags', 'Filetypes' ] }

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'plasticboy/vim-markdown',      { 'for': 'markdown'    }
Plug 'dhruvasagar/vim-table-mode',   { 'for': 'markdown'    }
Plug 'iamcco/markdown-preview.nvim', { 'for': 'markdown', 'do': 'cd app && ./install.sh' }
Plug 'bfrg/vim-jq',                  { 'for': 'jq'          }
Plug 'bfrg/vim-jqplay'
Plug 'mityu/vim-applescript',        { 'for': 'applescript' }

Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'onsails/lspkind-nvim'
Plug 'tami5/lspsaga.nvim'
Plug 'folke/trouble.nvim'

" tree-sitter fancyness
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

Plug 'glacambre/firenvim'

Plug 'eraserhd/parinfer-rust', { 'for': [ 'clojure', 'query' ], 'do': 'cargo build –release' }
Plug 'kovisoft/slimv',         { 'for': 'clojure' }
"Plug 'Olical/conjure'

call plug#end()
"}}}
"
