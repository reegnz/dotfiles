-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.swapfile = false
opt.nrformats:append({ "alpha" })
opt.listchars:append({ space = "·" })

-- turn on syntax highlighting for terraform.tfvars files
vim.treesitter.language.register("terraform", "terraform-vars")

-- uncomment to disable autoformat
-- vim.g.autoformat = false
--
opt.exrc = true
opt.secure = true
