return {
  "NeogitOrg/neogit",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
  },
  config = true,
  keys = {
    { "<leader>gg", "<cmd>lua require('neogit').open()<CR>", desc = "Neogit" },
  },
}
