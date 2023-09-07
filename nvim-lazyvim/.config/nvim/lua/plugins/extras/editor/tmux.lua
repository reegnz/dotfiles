return {
  "alexghergh/nvim-tmux-navigation",
  config = function()
    local nvim_tmux_nav = require("nvim-tmux-navigation")
    nvim_tmux_nav.setup({
      disable_when_zoomed = true,
      keybindings = {
        left = "<C-h>",
        down = "<C-j>",
        right = "<C-l>",
        up = "<C-k>",
        last_active = "<C-\\>",
        next = "<C-Space>",
      },
    })
  end,
}
