return {
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = 1
      vim.g.slime_bracketed_paste = 0
      vim.g.slime_preserve_curline = 0
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
        desc = "slime: send selection",
      },
      {
        "<leader>rr",
        "<Plug>SlimeLineSend",
        mode = "n",
        desc = "slime: send line",
      },
      {
        "<leader>rp",
        "<Plug>SlimeParagraphSend",
        mode = "n",
        desc = "slime: send paragraph",
      },
      {
        "<leader>rc",
        "<Plug>SlimeSendCell",
        mode = "n",
        desc = "slime: send fenced cell",
      },
      {
        -- Optional: A manual submit key just in case you ever want to
        -- review the pasted text in the terminal before sending it.
        "<leader>rs",
        function()
          vim.fn["slime#send"]("\r")
        end,
        mode = "n",
        desc = "slime: Submit (Send Enter)",
      },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "vim-slime", mode = { "n", "x" } },
      },
    },
  },
}
