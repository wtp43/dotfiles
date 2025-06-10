return {
  "stevearc/conform.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
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
    },
    default_format_opts = {
      timeout_ms = 500,
    },
  },
  -- config = require("conform").setup({
  --   typescript = function(bufnr)
  --     if require("conform").get_formatter_info("eslint_d", bufnr).available then
  --       return { "eslint_d", lsp_format = "never" }
  --       -- return { "eslint_d" }
  --     else
  --       return { "prettierd" }
  --     end
  --   end,
  --   format_after_save = {
  --     lsp_format = "fallback",
  --   },
  -- }),
}
