return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local colors = {
      blue = "#80aeff",
      cyan = "#07f7cb",
      black = "#080808",
      white = "##f0f1f5",
      red = "#ff5189",
      violet = "#dee4fa",
      grey = "#303030",
    }
    local bubbles_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.violet },
        b = { fg = colors.white, bg = colors.grey },
        c = { fg = colors.white },
      },

      insert = { a = { fg = colors.black, bg = colors.blue } },
      visual = { a = { fg = colors.black, bg = colors.cyan } },
      replace = { a = { fg = colors.black, bg = colors.red } },

      inactive = {
        a = { fg = colors.white, bg = colors.black },
        b = { fg = colors.white, bg = colors.black },
        c = { fg = colors.white },
      },
    }

    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local icons = LazyVim.config.icons

    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        theme = bubbles_theme,
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter" } },
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      -- tabline = {
      --   lualine_a = { "mode" },
      --   lualine_b = { "branch" },
      --
      --   lualine_c = {
      --     LazyVim.lualine.root_dir(),
      --     {
      --       "diagnostics",
      --       symbols = {
      --         error = icons.diagnostics.Error,
      --         warn = icons.diagnostics.Warn,
      --         info = icons.diagnostics.Info,
      --         hint = icons.diagnostics.Hint,
      --       },
      --     },
      --     { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      --     { LazyVim.lualine.pretty_path() },
      --   },
      --   lualine_x = {
      --     -- stylua: ignore
      --     {
      --       function() return require("noice").api.status.command.get() end,
      --       cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
      --       color = function() return {fg = Snacks.util.color("Statement") } end,
      --     },
      --     -- stylua: ignore
      --     {
      --       function() return require("noice").api.status.mode.get() end,
      --       cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
      --       color = function() return {fg = Snacks.util.color("Constant") } end,
      --     },
      --     -- stylua: ignore
      --     {
      --       function() return "  " .. require("dap").status() end,
      --       cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
      --       color = function() return {fg = Snacks.util.color("Debug") } end,
      --     },
      --     -- stylua: ignore
      --     {
      --       require("lazy.status").updates,
      --       cond = require("lazy.status").has_updates,
      --       color = function() return {fg = Snacks.util.color("Special") } end,
      --     },
      --     {
      --       "diff",
      --       symbols = {
      --         added = icons.git.added,
      --         modified = icons.git.modified,
      --         removed = icons.git.removed,
      --       },
      --       source = function()
      --         local gitsigns = vim.b.gitsigns_status_dict
      --         if gitsigns then
      --           return {
      --             added = gitsigns.added,
      --             modified = gitsigns.changed,
      --             removed = gitsigns.removed,
      --           }
      --         end
      --       end,
      --     },
      --   },
      --   lualine_y = {
      --     { "progress", separator = " ", padding = { left = 1, right = 0 } },
      --     { "location", padding = { left = 0, right = 1 } },
      --   },
      --   lualine_z = {
      --     function()
      --       return " " .. os.date("%R")
      --     end,
      --   },
      -- },
      -- winbar = {
      --   lualine_a = {},
      --   lualine_b = {},
      --   lualine_c = { LazyVim.lualine.pretty_path() },
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = {},
      -- },
      -- extensions = { "lazy" },
    }

    -- -- do not add trouble symbols if aerial is enabled
    -- -- And allow it to be overriden for some buffer types (see autocmds)
    -- if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
    --   local trouble = require("trouble")
    --   local symbols = trouble.statusline({
    --     mode = "symbols",
    --     groups = {},
    --     title = false,
    --     filter = { range = true },
    --     format = "{kind_icon}{symbol.name:Normal}",
    --     hl_group = "lualine_c_normal",
    --   })
    --   table.insert(opts.tabline.lualine_c, {
    --     symbols and symbols.get,
    --     cond = function()
    --       return vim.b.trouble_lualine ~= false and symbols.has()
    --     end,
    --   })
    -- end
    --
    return opts
  end,
}
