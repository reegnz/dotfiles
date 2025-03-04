return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    opts = {
      hints = {
        enabled = false,
      },
      provider = "ollama",
      auto_suggestions_provider = "ollama",
      vendors = {
        ollama = {
          __inherited_from = "openai",
          api_key_name = "",
          endpoint = "http://127.0.0.1:11434/v1",
          model = "codellama:7b",
        },
      },
      file_selector = {
        provider = "fzf",
        provider_opts = {},
      },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "Avante" },
  },
  {
    "saghen/blink.cmp",
    lazy = true,
    dependencies = {
      "saghen/blink.compat",
    },
    opts = {
      sources = {
        default = {
          "avante_commands",
          "avante_mentions",
          "avante_files",
        },
        compat = {
          "avante_commands",
          "avante_mentions",
          "avante_files",
        },
        providers = {
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },
    },
  },
}
