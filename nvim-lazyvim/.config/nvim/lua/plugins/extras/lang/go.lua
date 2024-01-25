return {
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "golangci-lint" })
    end,
  },
  {
    "nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        go = { "golangci-lint" },
      },
    },
  },
}
