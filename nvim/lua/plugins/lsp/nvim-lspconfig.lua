return {
  {
    "neovim/nvim-lspconfig",

    opts = {
      servers = {
        vtsls = {
          settings = {
            format = false,
          },
        },
      },
      --   eslint_d = {
      --     filetypes = {
      --       "javascript",
      --       "javascriptreact",
      --       "javascript.jsx",
      --       "typescript",
      --       "typescriptreact",
      --       "typescript.tsx",
      --     },
      --     settings = {
      --       -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      --       workingDirectories = { mode = "auto" },
      --       -- format = "auto_format",
      --       format = false,
      --       updateImportsOnFileMove = { enabled = "always" },
      --       suggest = {
      --         completeFunctionCalls = true,
      --       },
      --       -- inlayHints = {
      --       --   enumMemberValues = { enabled = true },
      --       --   functionLikeReturnTypes = { enabled = true },
      --       --   parameterNames = { enabled = "literals" },
      --       --   parameterTypes = { enabled = true },
      --       --   propertyDeclarationTypes = { enabled = true },
      --       --   variableTypes = { enabled = false },
      --       -- },
      --
      --       flags = os.getenv("DEBOUNCE_ESLINT") and {
      --         allow_incremental_sync = false,
      --         debounce_text_changes = 1000,
      --       } or nil,
      --       typescript = {
      --         updateImportsOnFileMove = { enabled = "always" },
      --         suggest = {
      --           completeFunctionCalls = true,
      --         },
      --         inlayHints = {
      --           enumMemberValues = { enabled = true },
      --           functionLikeReturnTypes = { enabled = true },
      --           parameterNames = { enabled = "literals" },
      --           parameterTypes = { enabled = true },
      --           propertyDeclarationTypes = { enabled = true },
      --           variableTypes = { enabled = false },
      --         },
      --       },
      --     },
      --   },
      -- },
      --   eslint_d = {
      --     filetypes = {
      --       "javascript",
      --       "javascriptreact",
      --       "javascript.jsx",
      --       "typescript",
      --       "typescriptreact",
      --       "typescript.tsx",
      --     },
      --     settings = {
      --       -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      --       workingDirectories = { mode = "auto" },
      --       -- format = "auto_format",
      --       format = false,
      --       updateImportsOnFileMove = { enabled = "always" },
      --       -- suggest = {
      --       --   completeFunctionCalls = true,
      --       -- },
      --       -- inlayHints = {
      --       --   enumMemberValues = { enabled = true },
      --       --   functionLikeReturnTypes = { enabled = true },
      --       --   parameterNames = { enabled = "literals" },
      --       --   parameterTypes = { enabled = true },
      --       --   propertyDeclarationTypes = { enabled = true },
      --       --   variableTypes = { enabled = false },
      --       -- },
      --     },
      --     -- flags = os.getenv("DEBOUNCE_ESLINT") and {
      --     --       allow_incremental_sync = false,
      --     --       debounce_text_changes = 1000,
      --     --     } or nil,
      --     --     typescript = {
      --     --       updateImportsOnFileMove = { enabled = "always" },
      --     --       suggest = {
      --     --         completeFunctionCalls = true,
      --     --       },
      --     --       inlayHints = {
      --     --         enumMemberValues = { enabled = true },
      --     --         functionLikeReturnTypes = { enabled = true },
      --     --         parameterNames = { enabled = "literals" },
      --     --         parameterTypes = { enabled = true },
      --     --         propertyDeclarationTypes = { enabled = true },
      --     --         variableTypes = { enabled = false },
      --     --       },
      --     --     },
      --     --   },
      --     -- },
      --     -- opts = {
      --     --   diagnostics = {
      --     --     virtual_text = false,
      --     --   },
      --     -- },
      --     --
      --   },
      -- },
      -- opts = function()
      -- local Keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- stylua: ignore
      -- vim.list_extend(Keys, {
      --   { "gd", "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
      --   { "gr", "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>", desc = "References", nowait = true },
      --   { "gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
      --   { "gy", "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
      -- })
      --    local lspconfig = require("lspconfig")
      --   -- local on_attach = function(client, bufnr)
      --   --   -- Disable hover in favor of Pyright
      --   --   client.server_capabilities.hoverProvider = false
      --   -- end
      --   -- lspconfig.ruff.setup({
      --   --   enabled = false,
      --   --   -- init_options = {
      --   --   --   settings = {
      --   --   --     -- Any extra CLI arguments for `ruff` go here.
      --   --   --     args = {},
      --   --   --   },
      --   --   -- },
      --   -- })
      --   lspconfig.pyright.setup({
      --     pyright = {
      --       disableOrganizeImports = true,
      --       disableTaggedHints = true,
      --     },
      --     python = {
      --       analysis = {
      --         diagnosticSeverityOverrides = {
      --           -- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#type-check-diagnostics-settings
      --           reportUndefinedVariable = "none",
      --         },
      --       },
      --     },
      --   })
      --   vim.diagnostic.config({ virtual_text = false })
      -- end,
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          multilines = {
            -- Enable multiline diagnostic messages
            enabled = true,

            -- Always show messages on all lines for multiline diagnostics
            always_show = true,
          },
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end,
  },
}
