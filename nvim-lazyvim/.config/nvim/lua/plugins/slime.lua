return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "neovim"
    vim.g.slime_no_mappings = 1
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.b.slime_cell_delimiter = "```"
      end,
    })
  end,
  keys = {
    {
      "<leader>rr",
      "<Plug>SlimeRegionSend",
      mode = "x",
      desc = "REPL: slime send selection",
      remap = true,
    },
    {
      "<leader>rl",
      "<Plug>SlimeLineSend",
      mode = "n",
      desc = "REPL: slime send line",
      remap = true,
    },
    {
      "<leader>rp",
      "<Plug>SlimeParagraphSend",
      mode = "n",
      desc = "REPL: Slime send paragraph",
      remap = true,
    },
    {
      "<leader>rc",
      "<Plug>SlimeSendCell",
      mode = "n",
      desc = "REPL: slime send fenced cell",
      remap = true,
    },
  },
}
