return {
  "folke/lazydev.nvim",
  dependencies = {
    { "DrKJeff16/wezterm-types", lazy = true, version = false },
  },
  opts = {
    library = {
      { path = "wezterm-types", mods = { "wezterm" } },
    },
  },
}
