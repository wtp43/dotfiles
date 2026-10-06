-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.maplocalleader = ","
vim.opt.clipboard = "unnamedplus"
if vim.env.SSH_TTY then
  -- OSC 52 paste waits for a terminal reply that may never come; reads of + then time out.
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = "OSC 52 copy-only",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
vim.go.background = "dark"
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/py3nvim/bin/python")
vim.opt.pumblend = 0
vim.opt.relativenumber = false
vim.opt.termguicolors = true

-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- vim.filetype.add({
--   pattern = {
--     [".*values.yaml"] = "helm",
--   },
-- })

vim.g.lazyvim_python_lsp = "basedpyright"

vim.opt["tabstop"] = 2
vim.opt["shiftwidth"] = 2
vim.expandtab = true
-- vim.g.lazyvim_eslint_auto_format = true
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf, async = true, lsp_fallback = true })
  end,
})
