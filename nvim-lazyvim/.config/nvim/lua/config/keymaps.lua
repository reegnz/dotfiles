-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Increment / Decrement
map("n", "==", "<C-a>", opts)
map("n", "--", "<C-x>", opts)

-- neovide configs below
-- if vim.g.neovide then
--   vim.o.guifont = "Hack Nerd Font"
--   local scale_default = 1.3
--   vim.g.neovide_scale_factor = scale_default
--   local change_scale_factor = function(delta)
--     vim.g.neovide_scale_factor = math.max(vim.g.neovide_scale_factor + delta, 0.1)
--   end
--   map("n", "<C-=>", function()
--     change_scale_factor(0.1)
--   end, opts)
--   map("n", "<C-->", function()
--     change_scale_factor(-0.1)
--   end, opts)
--   map("n", "<C-+>", function()
--     vim.g.neovide_transparency = math.min(vim.g.neovide_transparency + 0.05, 1.0)
--   end, opts)
--   map("n", "<C-_>", function()
--     vim.g.neovide_transparency = math.max(vim.g.neovide_transparency - 0.05, 0.0)
--   end, opts)
--   map("n", "<C-0>", function()
--     vim.g.neovide_scale_factor = scale_default
--   end, opts)
--   map("n", "<C-)>", function()
--     vim.g.neovide_transparency = 1.0
--   end, opts)
--   vim.g.neovide_input_macos_alt_is_meta = true
--   vim.defer_fn(function()
--     vim.cmd("NeovideFocus")
--   end, 25)
-- end
