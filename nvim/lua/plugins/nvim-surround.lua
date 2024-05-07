return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  opts = {
    keymaps = {
      change = "yc",
      change_line = "yC",
      normal = "ys",
      normal_line = "yS",
      delete = "ds",
    },
  },
}
