return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "fennel", "clojure" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "joker", "clj-kondo" })
    end,
  },
  {
    "stevearc/conform.nvim",
    ---@param opts conform.Context
    opts = {
      formatters_by_ft = {
        clojure = { "joker" },
        clojurescript = { "joker" },
        fennel = { "joker" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        clojure = { "clj-kondo", "joker" },
        clojurescript = { "clj-kondo", "joker" },
        fennel = { "fennel", "joker" },
      },
    },
  },
  {
    "gpanders/nvim-parinfer",
    ft = { "clojure", "clojurescript", "fennel" },
  },
  {
    "Olical/conjure",
    ft = { "clojure", "clojurescript", "fennel" },
    cmd = "ConjureSchool",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "PaterJason/cmp-conjure",
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "conjure" },
      }))
    end,
  },
}
