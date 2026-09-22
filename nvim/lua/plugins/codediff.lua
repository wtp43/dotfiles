return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gv", "<cmd>CodeDiff<cr>", desc = "CodeDiff (review changes)" },
  },
  opts = {
    -- sampled from Claude Code's rendered diff in this terminal, not its theme source values;
    -- char_delete is scaled like the green pair since no removed-word highlight was sampled
    highlights = {
      line_insert = "#265c11",
      line_delete = "#561004",
      char_insert = "#39841d",
      char_delete = "#7d1707",
    },
    diff = {
      -- must be a table; `true` is silently ignored
      gutter_signs = {},
      compact = true,
    },
    explorer = {
      width = 20,
      line_stats = {
        enabled = true,
      },
    },
  },
}
