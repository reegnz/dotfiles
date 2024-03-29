return {
  "stevearc/oil.nvim",
  cmds = {
    "Oil",
  },
  keys = {
    { "-", ":Oil<CR>", desc = "Open parent directory", remap = true },
  },
  opts = {
    --stylua: ignore
    keymaps = {
      ["<esc>"] = "actions.close",
      ["q"]     = "actions.close",
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
