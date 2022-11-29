" Modeline and Notes {{{
" vim: set sw=2 ts=2 sts=2 tw=78 et foldlevel=0 foldmethod=marker :
" }}}

" Install vim plug {{{
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs 
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  augroup install
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  augroup END
endif
unlet autoload_plug_path
" }}}

" Plugins {{{
call plug#begin()

Plug 'dstein64/vim-startuptime'

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dadbod' 
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'tpope/vim-speeddating'

" make gx more powerful
Plug 'stsewd/gx-extended.vim'

Plug 'wincent/terminus'
Plug 'easymotion/vim-easymotion'
"Plug 'ggandor/lightspeed.nvim'
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
Plug 'pwntester/octo.nvim'
Plug 'mhinz/vim-signify'


" file explorer
Plug 'kyazdani42/nvim-tree.lua'
Plug 'kyazdani42/nvim-web-devicons'

" FZF
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': [ 'Files', 'GFiles', 'Buffers', 'Colors', 'Ag', 'Rg', 'Lines', 'BLines', 'Tags', 'BTags', 'Marks', 'Windows', 'Locate', 'History', 'Snippets', 'Commits', 'BCommits', 'Maps', 'Helptags', 'Filetypes' ] }


"Plug 'plasticboy/vim-markdown',      { 'for': 'markdown'    }
"Plug 'dhruvasagar/vim-table-mode',   { 'for': 'markdown'    }
Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': 'markdown' }
Plug 'bfrg/vim-jq',                  { 'for': 'jq'          }
Plug 'bfrg/vim-jqplay'
Plug 'mityu/vim-applescript',        { 'for': 'applescript' }

Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'b0o/schemastore.nvim'
" Plug 'tami5/lspsaga.nvim'
" Plug 'folke/trouble.nvim'

Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'honza/vim-snippets'

" tree-sitter fancyness
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

" Plug 'glacambre/firenvim'

Plug 'eraserhd/parinfer-rust', { 'for': [ 'clojure', 'query' ]}
Plug 'kovisoft/slimv',         { 'for': 'clojure' }
" Plug 'Olical/conjure'

call plug#end()
"}}}
"
