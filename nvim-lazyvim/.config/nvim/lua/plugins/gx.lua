return {
  {
    "chrishrb/gx.nvim",
    keys = {
      { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
    },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      handlers = {
        jira = {
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(%u+-%d+)")
            if id then
              return vim.g.jira_host .. "/browse/" .. id
            end
          end,
        },
        cve = {
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(CVE[%d-]+)")
            if id then
              return "https://nvd.nist.gov/vuln/detail/" .. id
            end
          end,
        },
        ghsa = {
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(GHSA[%w-]+)")
            if id then
              return "https://github.com/advisories/" .. id
            end
          end,
        },
        -- the built-in github handler is still buggy, doesn't handle issues in braces for example
        -- that show up in squashed PR commit messages, which is quite common.
        gh_issue = {
          handle = function(mode, line, _)
            if not vim.fn.executable("gh") then
              return
            end
            local id = require("gx.helper").find(line, mode, "#(%d+)")
            if id then
              -- here I'm assuming the system has the gh cli installed
              -- TODO: add branch to get upstream URL from git cli output
              local cmd = string.format("gh issue view %s --json url --jq .url", id)
              local lines
              local job = vim.fn.jobstart(cmd, {
                stdout_buffered = true,
                on_stdout = function(_, _lines)
                  lines = _lines
                end,
              })
              vim.fn.jobwait({ job })
              return lines[1]
            end
          end,
        },
      },
    },
  },
}
