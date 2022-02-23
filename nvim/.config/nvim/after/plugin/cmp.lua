-- Setup nvim-cmp.
local cmp = require 'cmp'
require'cmp_nvim_ultisnips'.setup{}
local ultisnips_mappings = require'cmp_nvim_ultisnips.mappings'

cmp.setup {
  enabled = function()
    -- disable completion in comments
    local context = require 'cmp.config.context'
    return not context.in_treesitter_capture("comment")
      and not context.in_syntax_group("Comment")
  end,
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(
      function(fallback)
        ultisnips_mappings.expand_or_jump_forwards(fallback)
      end,
      { "i", "s"}
    ),
    ["<S-Tab>"] = cmp.mapping(
      function(fallback)
        ultisnips_mappings.jump_backwards(fallback)
      end,
      { "i", "s"}
    ),
  },
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'ultisnips' },
      { name = 'buffer' },
      { name = 'path' },
  }),
  formatting = {
    format = require'lspkind'.cmp_format({
      with_text = true,
      before = function(entry, vim_item)
        vim_item.menu = '[' .. entry.source.name .. ']'
        return vim_item
      end
    })
  }
}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
sources = {
  { name = 'buffer' }
}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
})
})
