return {

  -- {
  --   "AlexvZyl/nordic.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("nordic").load()
  --   end,
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    enabled = false,
    opts = {
      -- transparent = true,
      -- style = "storm",
      terminal_colors = true,
      styles = {
        floats = "normal",
        comments = { italic = false },
        keywords = { italic = false },
      },
      transparent = true,
      -- on_init = function(config)
      --   if config.transparent == true then
      --     vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
      -- on_colors = function(colors)
      --   colors.orange = "#9DB9DA"
      --   colors.magenta = "#E9ECEF"
      --   colors.bg = "#212529"
      --   colors.fg = "#212529"
      --   colors.green = "#BA4B8E"
      -- end,
      -- on_highlights = function(highlights, colors)
      --   -- highlights["@variable.parameter"].fg = "#9BD9DA"
      --   highlights["@keyword"].fg = "#e1e8ff"
      --   highlights["@variable.member"].fg = "#1cfce6"
      --   highlights["@property"].fg = "#4fd6be"
      --   highlights["@variable.builtin"].fg = "#ABCDFF"
      --   highlights["@variable.parameter"].fg = "#ABCDFF"
      --   highlights["@variable.member"].fg = "#ABCDFF"
      --   highlights["@keyword.function"].fg = "#9DB9DA"
      --   --   highlights.DashboardHeader.fg = "#c9d3ff"
      --   --   highlights.DashboardIcon.fg = "#c9d3ff"
      --   --   highlights.DashboardKey.fg = "#c9d3ff"
      --   --   highlights.DashboardDesc.fg = "#c9d3ff"
      --   --   highlights.DashboardFooter.fg = "#ffc7fb"
      --   --   highlights.String.fg = "#b8f065"
      --   -- highlights.RainbowDelimiterOrange.fg = "#9DB9DA"
      --   -- highlights.TSRainbowOrange.fg = "#9DB9DA"
      --   --   highlights.NeogitHunkHeaderHighlight.fg = "#bad0ff"
      --   --   highlights.NeoTreeNormal.fg = colors.blue
      --   --   highlights.NeoTreeNormalNC.fg = colors.blue
      -- end,
    },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    -- you can do it like this with a config function
    config = function()
      require("catppuccin").setup({
        -- configurations
        flavour = "mocha",
        no_italic = true,
        -- transparent_background = true,
        term_colors = true,
        color_overrides = {
          mocha = {
            rosewater = "#C3FF00",
            -- flamingo = "#3eb0ed",
            flamingo = "#797c9c",
            red = "#d4507e",
            mauve = "#C3FF00",
            -- red = "#d14b93",
            pink = "#98de02",
            maroon = "#a6b0d8",
            peach = "#b2badb",
            yellow = "#00d9c3",
            green = "#CCDBFD",
            teal = "#d9527f",
            sky = "#abd0f7",
            -- sky = "#6a728a",
            sapphire = "#797c9c",
            blue = "#97aee6",
            -- lavender = "#a0a8f6",
            -- lavender = "#fdc221",
            lavender = "#97acfc",
            text = "#ced7eb",
            -- subtext1 = "#a6b0d8",
            subtext1 = "#D7E3FC",
            subtext0 = "#959ec2",
            overlay2 = "#848cad",
            overlay1 = "#717997",
            overlay0 = "#63677f",
            surface2 = "#505469",
            surface1 = "#505469",
            surface0 = "#363842",
            base = "#1a1b21",
            mantle = "#1a1b21",
            crust = "#0e0f16",
          },

          latte = {

            -- flamingo = "#d4d3d2",
            -- pink = "#fdc221",
            -- mauve = "#C3FF00",
            -- red = "#b91372",
            -- maroon = "#a6b0d8",
            -- peach = "#7a7396",
            -- yellow = "#7cfcfc",
            -- green = "#CCDBFD",
            -- teal = "#fc368f",
            -- sky = "#abd0f7",
            -- -- sky = "#6a728a",
            -- sapphire = "#68bae0",
            -- blue = "#96c9dc",
            -- -- lavender = "#a0a8f6",
            -- lavender = "#a6b9e0",
            -- text = "#ced7eb",
            -- -- subtext1 = "#a6b0d8",
            -- subtext1 = "#D7E3FC",
            -- subtext0 = "#959ec2",
            -- overlay2 = "#848cad",
            -- overlay1 = "#717997",
            -- overlay0 = "#63677f",
            -- surface2 = "#505469",
            -- surface1 = "#3e4255",
            -- surface0 = "#2c2f40",
            -- -- base = "#2a2738",
            base = "#d7dcde",
            -- -- mantle = "#141620",
            -- mantle = "#1c1e29",
            -- -- crust = "#0e0f16",
          },

          integrations = {
            treesitter = true,
            notify = true,
            flash = true,
            indent_blank = {
              enabled = true,
              colored_indent_levels = false,
            },
            noice = false,
            dashboard = true,
            blink_cmp = true,
            fzf = true,
            lsp_trouble = true,
            which_key = true,
            snacks = true,
          },
          highlights = require("catppuccin.groups.integrations.bufferline").get(),
        },
      })
    end,
    -- or just use opts table
    opts = {
      -- configurations
    },
  },
  -- {
  --   "gbprod/nord.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("nord").setup({})
  --     vim.cmd.colorscheme("nord")
  --   end,
  -- },
  -- {
  --   "NLKNguyen/papercolor-theme",
  --   init = function()
  --     vim.o.background = "light" -- or "dark".
  --   end,
  -- },
  -- {
  --   "pappasam/papercolor-theme-slim",
  --   init = function()
  --     vim.o.background = "light" -- or "dark".
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
