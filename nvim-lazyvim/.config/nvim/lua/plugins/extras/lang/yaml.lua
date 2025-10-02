return {
  "nvim-lspconfig",
  opts = {
    servers = {
      yamlls = {
        settings = {
          yaml = {
            format = {
              enable = false,
            },
          },
        },
      },
    },
  },
  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "yamlfmt" },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        yaml = { "yamllint" },
      },
    },
  },
  {
    "mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "yamlfmt",
        "yamllint",
      })
    end,
  },
}
