return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "cursor",
      mode = "agentic",
      acp_providers = {
        ["cursor"] = {
          command = "cursor-agent",
          args = { "acp" },
          auth_method = "cursor_login",
          env = {
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
  },
}
