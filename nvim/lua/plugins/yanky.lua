return {
  "gbprod/yanky.nvim",
  dependencies = { { "kkharji/sqlite.lua", enabled = not jit.os:find("Windows") } },
  opts = {
    preserve_cursor_position = {
      enabled = true,
    },
    highlight = { timer = 250 },
    ring = {
      history_length = 100,
      storage = "shada",
      sync_with_numbered_registers = true,
      cancel_event = "update",
      ignore_registers = { "_" },
      update_register_on_cycle = false,
      system_clipboard = {
        sync_with_ring = true,
      },
    },
    picker = {
      telescope = {
        mappings = {
          default = require("yanky.telescope.mapping").put("p"),
          i = {
            ["<c-k>"] = require("telescope.actions").move_selection_previous,
            ["<c-j>"] = require("telescope.actions").move_selection_next,
            ["<c-x>"] = require("yanky.telescope.mapping").delete(),
          },
          n = {
            r = require("yanky.telescope.mapping").set_register(require("yanky.utils").get_default_register()),
          },
        },
      },
    },
  },
  keys = {
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
    {
      "<leader>j",
      function()
        require("telescope").extensions.yank_history.yank_history({})
      end,
      desc = "Open Yank History",
    },
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
    { "<c-p>", "<Plug>(YankyPreviousEntry)", mode = { "n" } },
    { "<c-n>", "<Plug>(YankyNextEntry)", mode = { "n" } },
  },
}
