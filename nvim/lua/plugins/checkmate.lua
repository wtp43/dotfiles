return {
  "bngarren/checkmate.nvim",
  ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
  opts = {
    -- your configuration here
    -- or leave empty to use defaults
    keys = {
      ["<leader>Tt"] = "toggle", -- Toggle todo item
      ["<leader>Tc"] = "check", -- Set todo item as checked (done)
      ["<leader>Tu"] = "uncheck", -- Set todo item as unchecked (not done)
      ["<leader>Tn"] = "create", -- Create todo item
      ["<leader>TR"] = "remove_all_metadata", -- Remove all metadata from a todo item
      ["<leader>Ta"] = "archive", -- Archive checked/completed todo items (move to bottom section)
    },
  },
}
