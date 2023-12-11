return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "hcl" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        terragrunt = {
          command = "terragrunt",
          args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
          stdin = false,
          condition = function(self, ctx)
            return vim.fs.basename(ctx.filename) ~= "terragrunt.hcl"
          end,
        },
      },
      formatters_by_ft = {
        hcl = { "terragrunt" },
      },
    },
  },
}
