require'lualine'.setup {
  options = {
    theme = 'gruvbox',
  },
  extensions = {
    "nvim-tree"
  },
}

require'nvim-tree'.setup{
  -- disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  diagnostics = {
    enable = true,
  },
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
    update_root = true,
  },
}

-- shows LSP status on bottom right corner
require'fidget'.setup{}
