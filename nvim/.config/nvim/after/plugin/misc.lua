require'lualine'.setup {
  extensions = {
    "nvim-tree"
  },
}
require'trouble'.setup {}
require'nvim-tree'.setup{
  disable_netrw = false,
  hijack_netrw = false,
  diagnostics = {
    enable = true,
  },
  update_cwd = {
    enable = true,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
}
