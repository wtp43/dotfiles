return {
  "nvim-neotest/neotest",
  lazy = false,
  dependencies = {
    "marilari88/neotest-vitest",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      ["neotest-vitest"] = {},
      ["neotest-python"] = {},
    },
  },
}
