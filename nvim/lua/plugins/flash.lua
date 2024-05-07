return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    highlight = {
      backdrop = false,
    },
    modes = {
      search = {
        forward = false,
      },
      char = {
        matches = true,
        enabled = true,
        jump_labels = false,
        highlight = { backdrop = false },
        multi_line = true,
      },
    },
  },
}
