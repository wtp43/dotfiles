-- Inside herdr (no $TMUX), move between nvim windows and hand focus to herdr at
-- the edge; ~/.config/herdr/navigate.sh sends ctrl+h/j/k/l here while nvim runs.
local function navigate(wincmd, direction, tmux_cmd)
  return function()
    local herdr_pane = vim.env.HERDR_PANE_ID
    if vim.env.TMUX or not herdr_pane then
      vim.cmd(tmux_cmd)
      return
    end
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. wincmd)
    if vim.api.nvim_get_current_win() == win then
      vim.system({ vim.env.HERDR_BIN_PATH or "herdr", "pane", "focus", "--pane", herdr_pane, "--direction", direction })
    end
  end
end

return {
  "christoomey/vim-tmux-navigator",
  -- Its default maps would replace the keys below when lazy loads it.
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", navigate("h", "left", "TmuxNavigateLeft") },
    { "<c-j>", navigate("j", "down", "TmuxNavigateDown") },
    { "<c-k>", navigate("k", "up", "TmuxNavigateUp") },
    { "<c-l>", navigate("l", "right", "TmuxNavigateRight") },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
