return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gclog", "GBrowse", "Gdiffsplit", "Gvdiffsplit" },
    -- stylua: ignore
    keys = {
      { "<leader>gs", ":G<cr>",       desc = "fugitive status",                  remap = true },
      { "<leader>gl", ":Gclog<cr>",   desc = "fugitive log",                     remap = true },
      { "<leader>gf", ":Gclog %<cr>", desc = "git log (current file)(fugitive)", remap = true },
      { "<leader>gb", ":G blame<cr>", desc = "git blame (fugitive)",             remap = true },
      { "<leader>go", ":GBrowse<cr>", desc = "open in browser (fugitive)",       remap = true, mode = { "n", "v" } },
    },
    dependencies = "tpope/vim-rhubarb",
  },
  {
    "reegnz/vim-abolish",
    branch = "fix_space_case",
    keys = {
      { "<leader>ac.", "<Plug>(abolish-coerce).", desc = "dot.case", mode = { "x", "o", "n" } },
      { "<leader>ac_", "<Plug>(abolish-coerce)_", desc = "snake_case", mode = { "x", "o", "n" } },
      { "<leader>ac-", "<Plug>(abolish-coerce)-", desc = "kebab-case", mode = { "x", "o", "n" } },
      { "<leader>acc", "<Plug>(abolish-coerce)c", desc = "camelCase", mode = { "x", "o", "n" } },
      { "<leader>acm", "<Plug>(abolish-coerce)m", desc = "MixedCase", mode = { "x", "o", "n" } },
      { "<leader>acu", "<Plug>(abolish-coerce)u", desc = "UPPER_CASE", mode = { "x", "o", "n" } },
      { "<leader>acu", "<Plug>(abolish-coerce)u", desc = "UPPER_CASE", mode = { "x", "o", "n" } },
      { "<leader>ac<space>", "<Plug>(abolish-coerce)<space>", desc = "space case", mode = { "x", "o", "n" } },
    },
    opts = function(_) end,
    config = function()
      vim.g.abolish_no_mappings = false
    end,
  },
  -- Displays a popup with possible key bindings of the command you started typing
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>a"] = { name = "abolish" },
        ["<leader>ac"] = { name = "coerce" },
      },
    },
  },
}
