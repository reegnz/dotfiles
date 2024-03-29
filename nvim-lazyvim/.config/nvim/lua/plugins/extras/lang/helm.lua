return {
  {
    "towolf/vim-helm",
    ft = "helm",
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        helm_ls = {},
      },
    },
  },
}
