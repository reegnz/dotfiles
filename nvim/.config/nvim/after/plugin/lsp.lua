-- Setup lspconfig.
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    local function nnoremap(key, value)
        buf_set_keymap('n', key, value, {noremap = true, silent = true})
    end

    local function vnoremap(key, value)
        buf_set_keymap('v', key, value, {noremap = true, silent = true})
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    nnoremap('gD',        '<cmd>lua vim.lsp.buf.declaration()<CR>')
    nnoremap('gd',        '<cmd>lua vim.lsp.buf.definition()<CR>')
    nnoremap('<C-]>',     '<cmd>lua vim.lsp.buf.definition()<CR>')
    nnoremap('gr',        '<cmd>lua vim.lsp.buf.references()<CR>')
    nnoremap('gi',        '<cmd>lua vim.lsp.buf.implementation()<CR>')
    nnoremap('K',         '<cmd>lua vim.lsp.buf.hover()<CR>')
    nnoremap('<C-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    nnoremap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
    nnoremap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
    nnoremap('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
    nnoremap('<space>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    nnoremap('<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    nnoremap('<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    nnoremap('<space>e',  '<cmd>lua vim.diagnostic.open_float()<CR>')
    nnoremap('[d',        '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    nnoremap(']d',        '<cmd>lua vim.diagnostic.goto_next()<CR>')
    nnoremap('<space>q',  '<cmd>lua vim.diagnostic.setloclist()<CR>')

    if client.server_capabilities.documentFormattingProvider then
            nnoremap('<space>f', '<cmd>lua vim.lsp.buf.format {async = true}<CR>')
    elseif client.server_capabilities.documentRangeFormattingProvider then
            nnoremap('<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>')
    end

    if client.server_capabilities.documentHighlight then
        vim.api.nvim_exec([[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]], false)
    end
end

local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lsp_defaults = {
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities
}
lspconfig.util.default_config = vim.tbl_deep_extend(
    'keep',
    lsp_defaults,
    lspconfig.util.default_config
)

mason.setup {
    providers = {
        -- resolve github stuff locally
        "mason.providers.client",
    },
}
mason_lspconfig.setup {
    automatic_installation = true
}


local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
lspconfig.lua_ls.setup {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            format = {
                enable = true,
            },

            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {enable = false}
        }
    }
}
lspconfig.gopls.setup {
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            staticcheck = true,
            usePlaceholders = true,
            analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedvariable = true,
                unusedwrite = true,
                shadow = true,
                useany = true,
            },
            codelenses = {
                generate = true,
            },
            vulncheck = "Imports",
            gofumpt = true,
        }
    }
}
lspconfig.jdtls.setup { -- java
    filetypes = {'java', 'groovy'}
        -- root_dir = function(fname)
        --     return lspconfig.util.root_pattern('.git', 'pom.xml', 'build.gradle', 'settings.gradle')(fname) or vim.fn.getcwd()
        -- end
}
lspconfig.efm.setup { -- General purpose language server
    -- init_options = {documentFormatting = true},
    filetypes = {
        'vim', 'dockerfile', 'markdown', 'yaml', 'sh', 'python', 'json', 'lua', 'gitcommit',
    }
}

lspconfig.yamlls.setup {
    settings = {
        yaml = {
            schemas = {
                kubernetes = "/*.k8s.yaml"
            }
        }
    }
}

lspconfig.ltex.setup {}


lspconfig.pyright.setup {} -- python
lspconfig.terraformls.setup {}
lspconfig.tflint.setup {} -- terraform lint
lspconfig.bashls.setup {}
lspconfig.vimls.setup {}
-- lspconfig.rust_analyzer.setup {}
-- lspconfig.tsserver.setup {} -- typescript
lspconfig.zls.setup {} -- zig

lspconfig.emmet_ls.setup{}
lspconfig.tsserver.setup{}
