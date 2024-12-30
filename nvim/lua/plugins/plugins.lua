return { -- lazy.nvim
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 800
    end,
    opts = {},
  },

  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { multiline = true },
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
