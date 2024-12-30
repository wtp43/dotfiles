return {
  "stevearc/oil.nvim",
  enabled = true,
  opts = {
    float = {
      max_width = 60,
      max_height = 30,
    },
    lsp_file_methods = {
      -- Time to wait for LSP file operations to complete before skipping
      timeout_ms = 1000,
      -- Set to true to autosave buffers that are updated with LSP willRenameFiles
      -- Set to "unmodified" to only save unmodified buffers
      autosave_changes = true,
    },
    keymaps = {
      ["<Esc>"] = "actions.close",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = false,
    },
  },

  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
