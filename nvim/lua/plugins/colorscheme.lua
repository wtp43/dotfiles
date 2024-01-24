return {
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {
      transparent = true,
      style = "moon",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(colors)
        colors.orange = "#ffc800"
        colors.magenta = "#aaadbd"
      end,
      on_highlights = function(highlights, colors)
        highlights["@variable.parameter"].fg = "#97defc"
        highlights["@keyword"].fg = "#fc72b5"
        highlights["@variable.member"].fg = "#1cfce6"
        highlights["@property"].fg = "#4fd6be"
        highlights["@variable"].fg = "#c9d3f5"
        highlights["@keyword.function"].fg = "#edb6fc"
        highlights.DashboardHeader.fg = "#c9d3ff"
        highlights.DashboardIcon.fg = "#c9d3ff"
        highlights.DashboardKey.fg = "#c9d3ff"
        highlights.DashboardDesc.fg = "#c9d3ff"
        highlights.DashboardFooter.fg = "#ffc7fb"
        highlights.String.fg = "#b8f065"
        highlights.RainbowDelimiterOrange.fg = "#e0ccff"
        highlights.TSRainbowOrange.fg = "#e0ccff"
        highlights.NeogitHunkHeaderHighlight.fg = "#bad0ff"
        highlights.NeoTreeNormal.fg = colors.blue
        highlights.NeoTreeNormalNC.fg = colors.blue
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-moon",
    },
  },
}
