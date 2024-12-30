-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ","
-- vim.opt.clipboard = { "unnamed", "unnamedplus" }
vim.go.background = "dark"
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.g.python3_host_prog = "/Users/wt/.pyenv/versions/py3nvim/bin/python"
vim.opt.pumblend = 0
vim.opt.relativenumber = false
vim.opt.termguicolors = true

-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.filetype.add({
  pattern = {
    [".*values.yaml"] = "helm",
  },
})
-- vim.opt.statuscolumn = ""
vim.opt.signcolumn = "yes:1"
