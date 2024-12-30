return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  config = true,
  opts = {
    float_diff = false,
    layout = "right_bottom",
  },
  keys = { -- load the plugin only when using it's keybinding:
    { "<leader>uu", "<cmd>lua require('undotree').toggle()<cr>" },
    { "<leader>uc", "<cmd>lua require('undotree').close()<cr>" },
  },
}
