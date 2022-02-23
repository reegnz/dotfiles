-- Setup lspconfig.
require'lspsaga'.setup{}


local cmp_nvim_lsp = require 'cmp_nvim_lsp'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
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
    nnoremap('gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
    nnoremap('gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
    nnoremap('<C-]>',      '<cmd>lua vim.lsp.buf.definition()<CR>')
    -- nnoremap('K',       '<cmd>lua vim.lsp.buf.hover()<CR>')
    nnoremap('gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
    nnoremap('gr',         '<cmd>lua vim.lsp.buf.references()<CR>')
    nnoremap('<C-k>',      '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    nnoremap('<space>wa',  '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
    nnoremap('<space>wr',  '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
    nnoremap('<space>wl',  '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
    nnoremap('<space>D',   '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    nnoremap('<space>rn',  '<cmd>lua vim.lsp.buf.rename()<CR>')
    nnoremap('<space>ca',  '<cmd>lua vim.lsp.buf.code_action()<CR>')
    nnoremap('<space>e',   '<cmd>lua vim.diagnostic.open_float()<CR>')
    nnoremap('[d',         '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    nnoremap(']d',         '<cmd>lua vim.diagnostic.goto_next()<CR>')
    nnoremap('<space>q',   '<cmd>lua vim.diagnostic.setloclist()<CR>')
    nnoremap('<space>f',   '<cmd>lua vim.lsp.buf.formatting()<CR>')

    -- saga
    nnoremap('K',          '<cmd>Lspsaga hover_doc<CR>')
    nnoremap('<leader>ca', '<cmd>Lspsaga code_action<CR>')
    vnoremap('<leader>ca', '<cmd>Lspsaga code_action<CR>')
    nnoremap('gs',         '<cmd>Lspsaga signature_help<CR>')
    nnoremap('gr',         '<cmd>Lspsaga rename<CR>')
    nnoremap('gd',         '<cmd>Lspsaga preview_definition<CR>')
    nnoremap('[e',         '<cmd>Lspsaga diagnostic_jump_next<CR>')
    nnoremap(']e',         '<cmd>Lspsaga diagnostic_jump_prev<CR>')
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
--
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local lsp_servers = {
    efm = {
        -- init_options = {documentFormatting = true},
        filetypes = {
            'vim', 'dockerfile', 'markdown', 'yaml', 'sh', 'python', 'json',
            'lua', 'gitcommit'
        }
    },
    sumneko_lua = {
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
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {enable = false}
            }
        }
    },
    pyright = {},
    gopls = {},
    terraformls = {},
    tflint = {},
    bashls = {},
    vimls = {},
    rust_analyzer = {},
    jdtls = {
      root_dir = function(fname)
        return require'lspconfig'.util.root_pattern('pom.xml', 'gradle.build', '.git')(fname) or vim.fn.getcwd()
      end
    },
    tsserver = {}
}
local servers = require 'nvim-lsp-installer.servers'
for lsp, config in pairs(lsp_servers) do
    local server_available, requested_server = servers.get_server(lsp)
    if server_available then
        if not requested_server:is_installed() then
            requested_server:install()
        end
        requested_server:on_ready(function()
            local opts = {
                on_attach = on_attach,
                flags = {debounce_text_changes = 150},
                capabilities = capabilities
            }
            for k, v in pairs(config) do opts[k] = v end
            requested_server:setup(opts)
        end)
    end
end
