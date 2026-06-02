-- Start the Nvim RPC server on a well-known socket under ~/.cache/nvim/servers/.
-- Socket name: <cwd-basename>-<pid>.sock  (unique per process, human-readable in a picker)
-- VimLeavePre cleans it up; crashed instances leave stale files the agent should skip.
local _nvim_sock = nil

local function nvim_sock_path()
  if _nvim_sock then return _nvim_sock end
  local dir = vim.fn.expand("~/.cache/nvim/servers")
  vim.fn.mkdir(dir, "p")
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  _nvim_sock = dir .. "/" .. cwd .. "-" .. vim.fn.getpid() .. ".sock"
  return _nvim_sock
end

vim.api.nvim_create_user_command("NvimListen", function()
  local sock = nvim_sock_path()
  for _, addr in ipairs(vim.fn.serverlist()) do
    if addr == sock then
      vim.notify("Already listening: " .. sock, vim.log.levels.INFO)
      return
    end
  end
  local started = vim.fn.serverstart(sock)
  if started ~= "" then
    vim.notify("Nvim RPC: " .. started, vim.log.levels.INFO)
  else
    vim.notify("Failed to start RPC server at " .. sock, vim.log.levels.ERROR)
  end
end, { desc = "Start Nvim RPC on ~/.local/state/nvim/servers/<cwd>-<pid>.sock" })

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if _nvim_sock then vim.fn.delete(_nvim_sock) end
  end,
})

return {}
