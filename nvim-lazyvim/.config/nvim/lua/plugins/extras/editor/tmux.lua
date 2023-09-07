return {
  "alexghergh/nvim-tmux-navigation",
  keys = {
    "<C-h>",
    "<C-j>",
    "<C-k>",
    "<C-l>",
    "<C-\\>",
    "<C-Space>",
  },
  config = function()
    local nvim_tmux_nav = require("nvim-tmux-navigation")
    nvim_tmux_nav.setup({
      disable_when_zoomed = true,
      --stylua: ignore
      keybindings = {
        left        = "<C-h>",
        down        = "<C-j>",
        right       = "<C-l>",
        up          = "<C-k>",
        last_active = "<C-\\>",
        next        = "<C-Space>",
      },
    })
  end,
}
