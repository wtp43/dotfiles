local function select(query)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end
end

local function swap(method, query)
  return function()
    require("nvim-treesitter-textobjects.swap")[method](query)
  end
end

local function move(method, query, group)
  return function()
    require("nvim-treesitter-textobjects.move")[method](query, group)
  end
end

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    select = { lookahead = true },
    move = {
      keys = {
        goto_next_start = {
          ["]f"] = "@call.outer",
          ["]m"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]i"] = "@conditional.outer",
          ["]l"] = "@loop.outer",
        },
        goto_next_end = {
          ["]F"] = "@call.outer",
          ["]M"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]I"] = "@conditional.outer",
          ["]L"] = "@loop.outer",
        },
        goto_previous_start = {
          ["[f"] = "@call.outer",
          ["[m"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[i"] = "@conditional.outer",
          ["[l"] = "@loop.outer",
        },
        goto_previous_end = {
          ["[F"] = "@call.outer",
          ["[M"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[I"] = "@conditional.outer",
          ["[L"] = "@loop.outer",
        },
      },
    },
  },
  keys = {
    { "a=", select("@assignment.outer"), mode = { "x", "o" }, desc = "Select outer part of an assignment" },
    { "i=", select("@assignment.inner"), mode = { "x", "o" }, desc = "Select inner part of an assignment" },
    { "l=", select("@assignment.lhs"), mode = { "x", "o" }, desc = "Select left hand side of an assignment" },
    { "r=", select("@assignment.rhs"), mode = { "x", "o" }, desc = "Select right hand side of an assignment" },

    { "a:", select("@property.outer"), mode = { "x", "o" }, desc = "Select outer part of an object property" },
    { "i:", select("@property.inner"), mode = { "x", "o" }, desc = "Select inner part of an object property" },
    { "l:", select("@property.lhs"), mode = { "x", "o" }, desc = "Select left part of an object property" },
    { "r:", select("@property.rhs"), mode = { "x", "o" }, desc = "Select right part of an object property" },

    { "aa", select("@parameter.outer"), mode = { "x", "o" }, desc = "Select outer part of a parameter/argument" },
    { "ia", select("@parameter.inner"), mode = { "x", "o" }, desc = "Select inner part of a parameter/argument" },
    { "ai", select("@conditional.outer"), mode = { "x", "o" }, desc = "Select outer part of a conditional" },
    { "ii", select("@conditional.inner"), mode = { "x", "o" }, desc = "Select inner part of a conditional" },
    { "al", select("@loop.outer"), mode = { "x", "o" }, desc = "Select outer part of a loop" },
    { "il", select("@loop.inner"), mode = { "x", "o" }, desc = "Select inner part of a loop" },
    { "af", select("@call.outer"), mode = { "x", "o" }, desc = "Select outer part of a function call" },
    { "if", select("@call.inner"), mode = { "x", "o" }, desc = "Select inner part of a function call" },
    { "am", select("@function.outer"), mode = { "x", "o" }, desc = "Select outer part of a method/function definition" },
    { "im", select("@function.inner"), mode = { "x", "o" }, desc = "Select inner part of a method/function definition" },
    { "ac", select("@class.outer"), mode = { "x", "o" }, desc = "Select outer part of a class" },
    { "ic", select("@class.inner"), mode = { "x", "o" }, desc = "Select inner part of a class" },

    { "<leader>na", swap("swap_next", "@parameter.inner"), desc = "Swap parameter with next" },
    { "<leader>n:", swap("swap_next", "@property.outer"), desc = "Swap object property with next" },
    { "<leader>nm", swap("swap_next", "@function.outer"), desc = "Swap function with next" },
    { "<leader>pa", swap("swap_previous", "@parameter.inner"), desc = "Swap parameter with previous" },
    { "<leader>p:", swap("swap_previous", "@property.outer"), desc = "Swap object property with previous" },
    { "<leader>pm", swap("swap_previous", "@function.outer"), desc = "Swap function with previous" },

    -- LazyVim's move keys always read the "textobjects" group; these need other groups.
    { "]s", move("goto_next_start", "@scope", "locals"), mode = { "n", "x", "o" }, desc = "Next scope" },
    { "]z", move("goto_next_start", "@fold", "folds"), mode = { "n", "x", "o" }, desc = "Next fold" },
  },
}
