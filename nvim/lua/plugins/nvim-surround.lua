return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("n", "yc", "<Plug>(nvim-surround-change)", { desc = "Change a surrounding pair" })
    vim.keymap.set("n", "yC", "<Plug>(nvim-surround-change-line)", { desc = "Change a surrounding pair on new lines" })
  end,
}
