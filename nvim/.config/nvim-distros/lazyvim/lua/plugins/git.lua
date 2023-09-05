return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
    },
  },
  {
    "tpope/vim-rhubarb",
    cmd = { "GBrowse" },
    dependencies = "tpope/vim-fugitive",
  },
}
