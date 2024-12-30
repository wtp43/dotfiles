return {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    "marilari88/neotest-vitest",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      ["neotest-vitest"] = {},
      ["neotest-python"] = {},
    },
  },
}
