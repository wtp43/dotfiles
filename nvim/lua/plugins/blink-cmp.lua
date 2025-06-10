return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "v0.*", -- REQUIRED `tag` needed to download pre-built binary
  dependencies = { "codeium.nvim", "saghen/blink.compat" },
  opts = {
    enabled = function()
      local path = vim.api.nvim_buf_get_name(0)
      if string.find(path, "oil://", 1, true) == 1 then
        return false
      end
      return true
    end,
    snippets = {
      expand = function(snippet, _)
        return LazyVim.cmp.expand(snippet)
      end,
    },
    appearance = {
      -- sets the fallback highlight groups to nvim-cmp's highlight groups
      -- useful for when your theme doesn't support blink.cmp
      -- will be removed in a future release, assuming themes add support
      use_nvim_cmp_as_default = false,
      -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
    },
    completion = {
      keyword = {
        range = "prefix",
      },
      accept = {
        -- experimental auto-brackets support
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
          gap = 2,
        },
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
        },
      },
      ghost_text = {
        -- enabled = vim.g.ai_cmp,
        enabled = false,
      },
    },

    -- experimental signature help support
    -- signature = { enabled = true },

    -- sources = {
    --   -- adding any nvim-cmp sources here will enable them
    --   -- with blink.compat
    --   -- sdf
    --   default = { "lsp", "snippets", "buffer" },
    --
    --   compat = { "codeium" },
    --   providers = {
    --     codeium = {
    --       kind = "Codeium",
    --       score_offset = 100,
    --       async = true,
    --     },
    --   },
    -- },

    keymap = {
      preset = "super-tab",
      ["<C-y>"] = { "select_and_accept" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
    },
  },
}
