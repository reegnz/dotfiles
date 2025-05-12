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
  callback = function()
    if vim.o.number then
      vim.opt_local.relativenumber = false
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
  group = numbertoggle,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.opt_local.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
  group = numbertoggle,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

vim.api.nvim_create_user_command("TermHl", function()
  local b = vim.api.nvim_create_buf(false, true)
  local chan = vim.api.nvim_open_term(b, {})
  vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
  vim.api.nvim_buf_delete(0, { force = true })
  vim.api.nvim_win_set_buf(0, b)
end, { desc = "Highlights ANSI termcodes in curbuf" })
