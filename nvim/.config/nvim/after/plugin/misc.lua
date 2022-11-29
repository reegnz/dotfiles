local lsp_status = require('lsp-status')
lsp_status.config {
    diagnostics = false,
}
lsp_status.register_progress()

require'lualine'.setup {
  options = {
    theme = 'gruvbox',
  },
  sections = {
    lualine_c = { "filename", "require'lsp-status'.status()" }
  },
  extensions = {
    "nvim-tree"
  },
}

require'nvim-tree'.setup{
  disable_netrw = false,
  hijack_netrw = false,
  diagnostics = {
    enable = true,
  },
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
}

require'octo'.setup {}
