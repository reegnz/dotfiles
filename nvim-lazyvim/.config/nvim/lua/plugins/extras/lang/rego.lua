return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        regols = {},
        regal = {},
      },
    },
  },
  {
    "nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "rego" })
    end,
  },
  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        rego = { "opa_fmt" },
      },
    },
  },
  -- {
  --   "nvim-lint",
  --   opts = {
  --     linters_by_ft = {
  --       rego = { "regal" },
  --     },
  --   },
  -- },
  {
    "mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "opa",
        "regols",
        -- "regal",
      })
    end,
  },
}
