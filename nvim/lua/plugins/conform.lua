return {
  "stevearc/conform.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
  -- enabled = false,
  opts = {
    formatters_by_ft = {
      fish = { "fish_indent" },
      sh = { "shfmt" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      svelte = { "prettierd" },
      css = { "prettierd" },
      html = { "prettierd" },
      json = { "prettierd" },
      yaml = { "prettierd" },
      markdown = { "prettierd" },
      graphql = { "prettierd" },
      lua = { "stylua" },
      python = { "black", "isort" },
      -- sql = { "sql_formatter" },
      -- ["*"] = { "injected" },
    },
    formatters = {
      -- sql_formatter = {
      --   prepend_args = { "-c", vim.fn.expand("~/.config/sql_formatter.json") },
      -- },
      -- sqlfluff = {
      --   command = "sqlfluff",
      --   args = {
      --     "fix",
      --     "--dialect",
      --     "postgres",
      --     "--FIX-EVEN-UNPARSABLE",
      --     "-n",
      --     "-",
      --   },
      --   stdin = true,
      -- },
      -- injected = { options = { ignore_errors = false, lang_to_formatters = { sql = { "sql_formatter" } } } },
    },
    default_format_opts = {
      timeout_ms = 2000,
    },
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --   if vim.b.autoformat then
    --     local disable_filetypes = {}
    --     local lsp_format_opt
    --     if disable_filetypes[vim.bo[bufnr].filetype] then
    --       lsp_format_opt = "never"
    --     else
    --       lsp_format_opt = "fallback"
    --     end
    --     return {
    --       timeout_ms = 2000,
    --       lsp_format = lsp_format_opt,
    --     }
    --   else
    --     return
    --   end
    -- end,
  },
}
