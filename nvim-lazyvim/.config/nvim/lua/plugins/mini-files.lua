return {
  {
    "mini.files",
    -- lazy = false,
    keys = {
      {
        "<leader>m",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File",
      },
      {
        "<leader>M",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
      {
        "-",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
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
