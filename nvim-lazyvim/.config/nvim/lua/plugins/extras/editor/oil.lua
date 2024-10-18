return {
  {
    "stevearc/oil.nvim",
    event = { "VimEnter" },
    cmd = {
      "Oil",
    },
    keys = {
      -- { "-", "<CMD>Oil<CR>", desc = "Open in Oil", remap = true },
      { "<leader>fo", "<CMD>Oil<CR>", desc = "Open in Oil", remap = true },
    },
    opts = {
      --stylua: ignore
      keymaps = {
        ["<esc>"] = "actions.close",
        ["q"]     = "actions.close",
      },
    },
    config = function(opts)
      local function parse_git_status_output(proc)
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            line = line:gsub("/$", "")
            ret[line] = true
          end
        end
        return ret
      end

      local function new_git_status()
        return setmetatable({}, {
          __index = function(self, key)
            local ignore_proc = vim.system(
              { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
              {
                cwd = key,
                text = true,
              }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
              cwd = key,
              text = true,
            })
            local ret = {
              ignored = parse_git_status_output(ignore_proc),
              tracked = parse_git_status_output(tracked_proc),
            }
            rawset(self, key, ret)
            return ret
          end,
        })
      end

      local git_status = new_git_status()
      local refresh = require("oil.actions").refresh
      local orig_refresh = refresh.callback

      refresh.callback = function(...)
        git_status = new_git_status()
        orig_refresh(...)
      end

      local function hidden_files_git(name, bufnr)
        local dir = require("oil").get_current_dir(bufnr)
        local is_dotfile = vim.startswith(name, ".") and name ~= "../"
        if not dir then
          return is_dotfile
        end
        -- dotfiles are considered hidden unless tracked
        if is_dotfile then
          return not git_status[dir].tracked[name]
        else
          -- Check if file is gitignored
          return git_status[dir].ignored[name]
        end
      end

      opts = vim.tbl_extend("keep", {
        view_options = {
          is_hidden_file = hidden_files_git,
        },
      }, opts)

      require("oil").setup(opts)
    end,

    dependencies = {
      "echasnovski/mini.icons",
    },
  },
}
