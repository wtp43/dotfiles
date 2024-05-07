return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "gbprod/yanky.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local yanky = require("yanky.utils")
    telescope.setup({
      defaults = {
        path_display = { "truncate" },
        -- vimgrep_arguments = {},
        wrap_results = true,
        file_ignore_patterns = {
          "node_modules",
          "*-lock.json",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-r>"] = require("yanky.telescope.mapping").set_register(yanky.get_default_register()),
          },
        },
        layout_strategy = "vertical",
        layout_config = {
          width = 0.95,
        },
      },
    })
    telescope.load_extension("yank_history")
    telescope.load_extension("fzf")
    telescope.load_extension("noice")
    telescope.load_extension("aerial")
    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>af", "<cmd>Telescope aerial<CR>", { desc = "Open aerial" })
    keymap.set("n", "<leader>snl", "<cmd>Noice telescope<cr>", { desc = "Telescope Error Messages" })
    keymap.set("n", "<leader>tt", "<cmd>Telescope resume<cr>", { desc = "Open previous telescope buffer" })
    keymap.set(
      "n",
      "<leader>ff",
      "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>",
      { desc = "Fuzzy find files in cwd" }
    )
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
    keymap.set("n", "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in current buffer" })
    keymap.set("n", "<leader>fs", "<cmd>Telescope buffers<cr>", { desc = "Find in buffers" })
  end,
}
