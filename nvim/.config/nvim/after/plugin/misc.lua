require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  ensure_installed = "all",
}
require'lualine'.setup{}
require'trouble'.setup{}
