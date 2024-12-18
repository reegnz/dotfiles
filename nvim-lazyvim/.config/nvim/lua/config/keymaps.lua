-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Increment / Decrement
map("n", "==", "<C-a>", opts)
map("n", "--", "<C-x>", opts)

-- evaluate expression on line
map("n", "<leader>e", '^C<C-r>=<C-r>"<CR>')
