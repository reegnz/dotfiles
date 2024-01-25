return {
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "shellcheck" })
    end,
  },
  {
    "nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "conform.nvim",
    optional = true,
    opts = {
      formatters = {
        shfmt = {
          -- Override defaults with Google style guide
          prepend_args = { "-i", "2", "-ci" },
        },
      },
    },
  },
}
