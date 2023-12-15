return {
  "reegnz/gx-extended.nvim",
  branch = "dev",
  keys = {
    { "gx", mode = { "n", "v" } },
  },
  opts = {
    log_level = vim.log.levels.DEBUG,
    extensions = {
      {
        -- to use, set this somewhere:
        -- vim.g.gx_jira_url = https://jira.example.com/browse/
        name = "Open JIRA Issue",
        match_to_url = function(line_string)
          if vim.g.gx_jira_url then
            local ticket = string.match(line_string, "(%a+-%d+)")
            if ticket then
              return vim.g.gx_jira_url .. ticket
            else
              return nil
            end
          else
            return nil
          end
        end,
      },
      {
        name = "Google Search",
        match_to_url = function()
          local mode = vim.api.nvim_get_mode().mode
          local is_visual = mode:match("[vV\x16]")
          -- only trigger searches for visual selection
          if not is_visual then
            return nil
          end
          local vstart = vim.fn.getpos("v")
          local vend = vim.fn.getpos(".")
          if vstart[2] > vend[2] then
            vstart, vend = vend, vstart
          end
          if vstart[2] == vend[2] and vstart[3] > vend[3] then
            vstart, vend = vend, vstart
          end
          local lines = vim.api.nvim_buf_get_lines(0, vstart[2] - 1, vend[2], true)
          if #lines == 0 then
            return nil
          end
          lines[#lines] = string.sub(lines[#lines], 1, vend[3])
          lines[1] = string.sub(lines[1], vstart[3])
          local query = table.concat(lines, " ")
          return "https://google.com/search?q=" .. query
        end,
      },
    },
  },
}
