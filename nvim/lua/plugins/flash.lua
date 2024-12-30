return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    highlight = {
      backdrop = false,
    },
    modes = {
      search = {
        enabled = true,
        forward = false,
      },
      char = {
        matches = true,
        enabled = true,
        jump_labels = true,
        highlight = { backdrop = false },
        multi_line = true,
      },
    },
  },
}
