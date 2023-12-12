return {

  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 0
    end,
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    open_mapping = [[<c-\>]],
    keys = {
      { "<leader>td", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Open a horizontal terminal" },
      { "<c-/>", "<cmd>ToggleTerm direction=float<cr>", desc = "" },
    },
    opts = {},
  },

  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = vim.opt.sessionoptions:get() },
		-- stylua: ignore
		keys = {
		  { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
		  { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
		  { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
		},
  },

  {
    "max397574/better-escape.nvim",
    opts = {
      mapping = { "jk", "jj" }, -- a table with mappings to use
      timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
      clear_empty_lines = false, -- clear line after escaping if there is only whitespace
      keys = "<ESC>",
    },
    lazy = false,
  },

  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
    },
    lazy = false,
  },

  {
    "jinh0/eyeliner.nvim",
    opts = {
      highlight_on_key = true,
    },
  },
}
