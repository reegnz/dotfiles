return {
  "daliusd/ghlite.nvim",
  cmd = {
    "GHLitePRAddComment",
    "GHLitePRCheckout",
    "GHLitePRDeleteComment",
    "GHLitePRDiff",
    "GHLitePRDiffview",
    "GHLitePRLoadComments",
    "GHLitePROpenComment",
    "GHLitePRSelect",
    "GHLitePRUpdateComment",
    "GHLitePRView",
  },
  keys = {
    { "<leader>hs", ":GHLitePRSelect<cr>", desc = "PR Select" },
    { "<leader>ho", ":GHLitePRCheckout<cr>", desc = "PR Checkout" },
    { "<leader>hv", ":GHLitePRView<cr>", desc = "PR View" },
    { "<leader>hu", ":GHLitePRLoadComments<cr>", desc = "PR Load Comments" },
    { "<leader>hp", ":GHLitePRDiff<cr>", desc = "PR Diff" },
    { "<leader>hl", ":GHLitePRDiffview<cr>", desc = "PR Diffview" },
    { "<leader>ha", ":GHLitePRAddComment<cr>", desc = "PR Add Comment" },
    { "<leader>ha", ":GHLitePRAddComment<cr>", mode = "v", desc = "PR Add Comment" },
    { "<leader>hc", ":GHLitePRUpdateComment<cr>", desc = "PR Update Comment" },
    { "<leader>hd", ":GHLitePRDeleteComment<cr>", desc = "PR Delete Comment" },
    { "<leader>hg", ":GHLitePROpenComment<cr>", desc = "PR Open Comment" },
  },
  config = function()
    require("ghlite").setup({})
  end,
}
