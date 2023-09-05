-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
-- toggle relativenumber when in insert mode
-- autocmd BufLeave,FocusGained,InsertEnter * :set norelativenumber
-- autocmd BufEnter,FocusGained,InsertLeave * :set relativenumber

local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
  group = numbertoggle,
  pattern = "*",
  command = "setlocal norelativenumber",
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
  group = numbertoggle,
  pattern = "*",
  command = "setlocal relativenumber",
})
