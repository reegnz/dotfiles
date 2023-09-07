return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gclog", "GBrowse" },
    keys = {
      { "<leader>gs", ":G<cr>", desc = "fugitive status", remap = true },
      { "<leader>gl", ":Gclog<cr>", desc = "fugitive log", remap = true },
      { "<leader>gf", ":Gclog %<cr>", desc = "git log (current file)(fugitive)", remap = true },
      { "<leader>gb", ":G blame<cr>", desc = "git blame (fugitive)", remap = true },
      { "<leader>go", ":GBrowse<cr>", mode = { "n", "v" }, desc = "open in browser (fugitive)", remap = true },
    },
    dependencies = "tpope/vim-rhubarb",
  },
}
