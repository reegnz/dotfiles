-- local parsers = require'nvim-treesitter.parsers'.get_parser_configs()
-- parsers.gotmpl = {
--   install_info = {
--     url = "https://github.com/ngalaiko/tree-sitter-go-template",
--     files = {"src/parser.c"},
--   },
--   filetype = "gotmpl",
--   used_by = {
--     "gohtmltmpl",
--     "gotexttmpl",
--     "gotmpl",
--     "goyamltmpl",
--     -- "yaml",
--     "ctmpl",
--   },
-- }

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {"help"}, -- disable until conceal issue is fixed https://github.com/neovim/tree-sitter-vimdoc/issues/23
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  ensure_installed = "all",
  playground = {
    enable = true,
    persist_queries = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = "@function.outer",
        ['if'] = "@function.inner",

        ['aa'] = "@parameter.outer",
        ['ia'] = "@parameter.inner",

        ['av'] = "@variable.outer",
        ['iv'] = "@variable.inner",

        ['ab'] = "@block.outer",
        ['ib'] = "@block.inner",

        ['ac'] = "@comment.outer",
        ['as'] = "@statement.outer",
      },
    },
  },
  context_commentstring = {
    enable = true,
    config = {
      yaml = "# %s",
      gotmpl = "{{- /* %s */}}",
    },
  }
}
