return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local Keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- stylua: ignore
    vim.list_extend(Keys, {
      { "gd", "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
      { "gr", "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>", desc = "References", nowait = true },
      { "gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
      { "gy", "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
    })
      local lspconfig = require("lspconfig")
      local on_attach = function(client, bufnr)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
      lspconfig.ruff_lsp.setup({
        on_attach = on_attach,
        init_options = {
          settings = {
            -- Any extra CLI arguments for `ruff` go here.
            args = {},
          },
        },
      })
      lspconfig.pyright.setup({
        pyright = {
          disableOrganizeImports = true,
          disableTaggedHints = true,
        },
        python = {
          analysis = {
            diagnosticSeverityOverrides = {
              -- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#type-check-diagnostics-settings
              reportUndefinedVariable = "none",
            },
          },
        },
      })
    end,
  },
}
