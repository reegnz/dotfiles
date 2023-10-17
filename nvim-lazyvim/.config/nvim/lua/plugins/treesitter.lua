return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/playground",
    cmd = "TSPlayGroundToggle",
  },
  opts = {
    playground = {
      enable = true,
      persist_queries = true,
    },
    ensure_installed = {
      "query",
    },
  },
}
