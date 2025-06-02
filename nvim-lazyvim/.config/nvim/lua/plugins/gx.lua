return {
  {
    "chrishrb/gx.nvim",
    url = "https://github.com/reegnz/gx.nvim",
    branch = "develop",
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

        python_pep = {
          name = "python-pep",
          handle = function(mode, line, _)
            local id = require("gx.helper").find(line, mode, "PEP%s?-?(%d+)")
            if not id then
              return
            end
            return "https://peps.python.org/pep-" .. id
          end,
        },

        pyproject = {
          name = "pyproject",
          filename = "pyproject.toml",
          filetype = { "toml" },
          handle = function(_, _, _)
            local node = vim.treesitter.get_node()
            if not node then
              return
            end
            if node:type() ~= "string" then
              return
            end
            local dep_array = node:parent()
            if not dep_array or dep_array:type() ~= "array" then
              return
            end
            local pair = dep_array:parent()
            if not pair or dep_array:parent():type() ~= "pair" then
              return
            end
            local bare_key = dep_array:next_named_sibling()
            if not bare_key then
              bare_key = node:parent():prev_named_sibling()
            end
            if not bare_key then
              return
            end
            local start_line, start_col, end_line, end_col = bare_key:range()
            local line = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)[1]
            local key = line:sub(start_col, end_col)
            if not key then
              return
            end
            local table = pair:parent()
            if not table or table:type() ~= "table" then
              return
            end
            for child, _ in table:iter_children() do
              if child:named() then
                if child:type() == "bare_key" then
                  bare_key = child
                end
              end
            end
            if not bare_key then
              return
            end
            start_line, start_col, end_line, end_col = bare_key:range()
            line = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)[1]
            local table_key = line:sub(start_col + 1, end_col)
            if not table_key then
              return
            end
            if table_key == "project" then
              if key ~= "dependencies" then
                return
              end
            elseif table_key == "build-system" then
              -- Handle PEP 518
              if key ~= "requires" then
                return
              end
            elseif table_key ~= "dependency-groups" or table_key ~= "project.optional-dependencies" then
              return
            end
            start_line, start_col, end_line, end_col = node:range()
            line = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)[1]
            local package = line:sub(start_col + 2, end_col - 1) -- remove quotes
            if not package then
              return
            end
            -- deal with PEP 440 version ranges
            local _, _, new = package:find("^(.+)<.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*>.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*<=.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*>=.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*~=.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*!=.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*==.+")
            if new then
              ---@type string
              package = new
            end
            _, _, new = package:find("^(.+)%s*===.+")
            if new then
              ---@type string
              package = new
            end
            -- trim leading and trailing whitespace
            package = package:gsub("^%s*", "")
            package = package:gsub("%s*$", "")

            -- trim extras (PEP 508)
            package = package:gsub("%[.+%]$", "")
            if not package then
              return
            end
            return "https://pypi.org/project/" .. package
          end,
        },
      },
    },
  },
}
