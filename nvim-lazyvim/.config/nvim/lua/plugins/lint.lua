return {
  {
    "mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typos",
        "gitlint",
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["*"] = { "typos" },
        gitcommit = { "gitlint" },
      },
    },
  },
}
