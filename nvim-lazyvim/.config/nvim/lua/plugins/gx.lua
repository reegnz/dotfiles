return {
  {
    "chrishrb/gx.nvim",
    -- branch = "develop",
    -- dev = true,
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
  },
  -- custom gx handlers below
  {
    "gx.nvim",
    opts = {
      handlers = {
        jira = {
          name = "jira",
          handle = function(mode, line, handler_options)
            local id = require("gx.helper").find(line, mode, "(%u+-%d+)")
            if not id then
              return
            end
            if not handler_options.jira_host then
              print("handler_options.jira_host is undefined, cannot open JIRA link")
              return
            end
            return handler_options.jira_host .. id
          end,
        },

        cve_nist = {
          name = "cve-nist",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(CVE[%d-]+)")
            if id then
              return "https://nvd.nist.gov/vuln/detail/" .. id
            end
          end,
        },

        cve_org = {
          name = "cve-org",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(CVE[%d-]+)")
            if id then
              return "https://www.cve.org/CVERecord?id=" .. id
            end
          end,
        },
        cve_details = {
          name = "cve-details",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(CVE[%d-]+)")
            if id then
              return "https://www.cvedetails.com/cve/" .. id
            end
          end,
        },

        cve_ghsa = {
          name = "cve-ghsa",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(GHSA[%w-]+)")
            if id then
              return "https://github.com/advisories/" .. id
            end
          end,
        },

        cve_go = {
          name = "cve-go",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "(GO[%w-]+)")
            if id then
              return "https://pkg.go.dev/vuln/" .. id
            end
          end,
        },
      },
    },
  },
}
