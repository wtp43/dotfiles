return { -- lazy.nvim
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = { notification = false },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { multiline = true },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    open_mapping = [[<c-\>]],
    keys = {
      {
        "<leader>tv",
        function()
          local count = vim.v.count1
          require("toggleterm").toggle(count, 0, vim.loop.cwd(), "vertical")
        end,
        desc = "ToggleTerm (vertical)",
      },
      {
        "<leader>th",
        function()
          local count = vim.v.count1
          require("toggleterm").toggle(count, 10, vim.loop.cwd(), "horizontal")
        end,
        desc = "ToggleTerm (horizontal)",
      },
      {
        "<c-/>",
        function()
          local count = vim.v.count1
          require("toggleterm").toggle(count, 10, vim.loop.cwd(), "float")
        end,
        desc = "ToggleTerm (float)",
      },
      { "<leader>td", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Open a horizontal terminal" },

      -- { "<c-/>", "<cmd>ToggleTerm direction=float<cr>", desc = "" },
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
