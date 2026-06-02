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

map("n", ";", ":")

map("t", "<Esc>", [[<C-\><C-n>]], opts)

-- Launch an AI CLI in a split terminal with RPC (NVIM_ADDRESS).

vim.api.nvim_create_user_command("AIAgent", function(opts)
  local trimmed = vim.trim(opts.args)
  if trimmed == "" then
    vim.notify("AIAgent: specify a CLI command (e.g. cursor-agent)", vim.log.levels.ERROR)
    return
  end

  local sock = vim.v.servername
  if sock == "" then
    sock = vim.fn.serverstart(vim.fn.stdpath("run") .. "/nvim.sock")
    if sock == "" then
      vim.notify("AIAgent: RPC server could not be started", vim.log.levels.ERROR)
      return
    end
  end

  local tokens = vim.split(trimmed, "%s+", { trimempty = true })
  local escaped = vim.tbl_map(function(t)
    return vim.fn.shellescape(t)
  end, tokens)
  local cli = table.concat(escaped, " ")

  vim.cmd(string.format("vsplit | terminal env NVIM_ADDR=%s %s", vim.fn.shellescape(sock), cli))
end, {
  nargs = "+",
  complete = "shellcmd",
  desc = "Split window + terminal: AI CLI with NVIM_ADDR set",
})

vim.api.nvim_create_user_command("CursorAgent", function()
  vim.cmd("AIAgent cursor-agent")
end, { desc = "runs :AIAgent cursor-agent" })

vim.api.nvim_create_user_command("ClaudeCode", function()
  vim.cmd("AIAgent claude")
end, { desc = "runs :AIAgent zsh -c 'claude-code'" })

vim.api.nvim_create_user_command("PiCodingAgent", function()
  vim.cmd("AIAgent pi")
end, { desc = "runs :AIAgent pi" })
