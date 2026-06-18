return {
  {
    "mini.files",
    init = function()
      vim.api.nvim_create_user_command("MiniFiles", function(opts)
        require("mini.files").open(opts.args ~= "" and opts.args or vim.api.nvim_buf_get_name(0), true)
      end, { nargs = "?" })
    end,
    keys = {
      {
        "<leader>m",
        "<cmd>MiniFiles<cr>",
        desc = "Open mini.files (Directory of Current File)",
      },
      {
        "-",
        "<cmd>MiniFiles<cr>",
        desc = "Open mini.files (Directory of Current File)",
        remap = true,
      },
    },
    opts = {
      mappings = {
        go_in_plus = "<CR>",
        go_out_plus = "-",
      },
      options = {
        use_as_default_explorer = false,
      },
      windows = {
        preview = true,
        width_preview = 40,
      },
    },
  },
  { "neo-tree.nvim", enabled = false },
}
