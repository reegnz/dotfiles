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

        -- https://github.com/reegnz/dotfiles
        -- https://github.com/reegnz/dotfiles/blob/master/jq/.jq
        -- https://raw.githubusercontent.com/reegnz/dotfiles/refs/heads/master/jq/.jq
        local_github_clone = {
          name = "local_github_clone",
          handle = function(mode, line, handler_options)
            local opt = handler_options.local_github_clone
            if not opt or type(opt.roots) ~= "table" or type(opt.hosts) ~= "table" then
              return
            end
            if next(opt.roots) == nil or next(opt.hosts) == nil then
              return
            end

            local helper = require("gx.helper")
            local url = helper.find(line, mode, "(https?://[a-zA-Z%d_/%%%-%.~@\\+#=?&:*]+)")
              or helper.find(line, mode, "%[[%a%d%s.,?!:;@_{}~]*%]%((https?://[a-zA-Z0-9_/%-%.~@\\+#=?&]+)%)")
            if not url then
              return
            end
            url = url:gsub("\\([%p])", "%1")

            local function decode(s)
              return (
                s:gsub("%%(%x%x)", function(hex)
                  return string.char(tonumber(hex, 16))
                end)
              )
            end

            ---@param tail string
            local function gh_tail(owner, repo, tail)
              repo = repo:gsub("%.git$", "")
              if tail:match("^/issues") or tail:match("^/pull/") or tail:match("^/compare/") then
                return nil
              end
              if tail == "" or tail == "/" then
                return { owner = owner, repo = repo, kind = "root" }
              end
              local br, bp = tail:match("^/blob/([^/]+)/(.+)$")
              if br then
                return { owner = owner, repo = repo, kind = "blob", filepath = bp }
              end
              local tr, tp = tail:match("^/tree/([^/]+)/?(.*)$")
              if tr then
                local sub = tp or ""
                return sub == "" and { owner = owner, repo = repo, kind = "root" }
                  or { owner = owner, repo = repo, kind = "tree", filepath = sub }
              end
              return { owner = owner, repo = repo, kind = "root" }
            end

            --- raw.githubusercontent.com/{owner}/{repo}/{ref…}/{filepath}
            --- ref may be one segment ("main", SHA) or refs/heads/… / refs/tags/… (GH raw URLs).
            local function parse_raw(rest)
              rest = decode((rest or ""):match("^([^?#]*)") or "")
              local o, r, tail = rest:match("^/([^/]+)/([^/]+)/(.+)$")
              if not o or not r or not tail then
                return nil
              end
              r = r:gsub("%.git$", "")
              local fp = tail:match("^refs/heads/[^/]+/(.+)$") or tail:match("^refs/tags/[^/]+/(.+)$")
              if not fp then
                fp = select(2, tail:match("^([^/]+)/(.+)$"))
              end
              if not fp then
                return nil
              end
              return { owner = o, repo = r, kind = "blob", filepath = fp }
            end

            local parsed
            local _, _, host, rest = url:find("^https?://([^/]+)([^#]*)")
            if host then
              local ok = opt.hosts[host]
              if ok then
                if host == "raw.githubusercontent.com" then
                  parsed = parse_raw(rest)
                else
                  rest = ((rest or ""):match("^([^?#]*)") or "")
                  local path = decode(rest):match("^(.-)/?$") or rest
                  local o, r, t = path:match("^/([^/]+)/([^/]+)(/.*)$")
                  if not o then
                    o, r = path:match("^/([^/]+)/([^/]+)$")
                    t = ""
                  end
                  if o and r then
                    parsed = gh_tail(o, r, t or "")
                  end
                end
              end
            end

            if not parsed then
              return
            end

            local ph, po, pr = vim.pesc(host), vim.pesc(parsed.owner), vim.pesc(parsed.repo)
            local function origin_ok(out)
              out = vim.trim(out):gsub("%.git$", "")
              return out:match("^git@" .. ph .. ":" .. po .. "/" .. pr .. "$")
                or out:match("^ssh://git@" .. ph .. "/" .. po .. "/" .. pr .. "$")
                or out:match("^https://" .. ph .. "/" .. po .. "/" .. pr .. "$")
            end

            local repo_root
            for root in pairs(opt.roots) do
              root = vim.fs.normalize(root)
              for _, dir in ipairs({
                root .. "/" .. host .. "/" .. parsed.owner .. "/" .. parsed.repo,
                root .. "/" .. parsed.owner .. "/" .. parsed.repo,
                root .. "/" .. parsed.repo,
              }) do
                if vim.fn.isdirectory(dir) == 1 and vim.fn.isdirectory(dir .. "/.git") == 1 then
                  local out = vim.fn.system({ "git", "-C", dir, "remote", "get-url", "origin" })
                  if vim.v.shell_error == 0 and origin_ok(out) then
                    repo_root = dir
                    break
                  end
                end
              end
              if repo_root then
                break
              end
            end
            if not repo_root then
              return
            end

            local target = parsed.kind == "root" and repo_root or vim.fs.joinpath(repo_root, parsed.filepath)
            target = vim.fs.normalize(target)
            if vim.fn.filereadable(target) == 1 or vim.fn.isdirectory(target) == 1 then
              return target
            end
          end,
        },
      },

      handler_options = {
        -- PIL §11.5 sets. Hosts: github.com (web), raw.githubusercontent.com (raw file URLs).
        local_github_clone = {
          roots = {
            [vim.fs.normalize("~/repos")] = true,
          },
          hosts = {
            ["github.com"] = true,
            ["raw.githubusercontent.com"] = true,
          },
        },
      },
    },
    config = function(_, opts)
      require("gx").setup(opts)
      local gx_shell = require("gx.shell")
      local orig = gx_shell.execute_with_error
      ---@diagnostic disable-next-line: inject-field
      function gx_shell.execute_with_error(command, args, url)
        if type(url) == "string" and url ~= "" then
          if vim.fn.filereadable(url) == 1 or vim.fn.isdirectory(url) == 1 then
            vim.cmd.edit(vim.fn.fnameescape(url))
            return
          end
        end
        return orig(command, args, url)
      end
    end,
  },
}
