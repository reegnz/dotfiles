return {
  "ii14/neorepl.nvim",
  cmd = {
    "Repl",
    "ReplCurrent",
  },
  keys = {
    { "<leader>r", "<cmd>ReplCurrent<cr>", desc = "NeoRepl" },
  },
  config = function()
    vim.api.nvim_create_user_command("ReplCurrent", function()
      local buf = vim.api.nvim_get_current_buf()
      local win = vim.api.nvim_get_current_win()
      vim.cmd("split")
      require("neorepl").new({
        lang = "lua",
        buffer = buf,
        window = win,
      })
    end, {})
  end,
}
