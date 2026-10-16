-- Over etd, dev tmux runs inside the Mac tmux. Dev tmux answers the terminal query
-- itself, so Ghostty is never detected, and the Mac tmux drops a single-wrapped image.
return {
  "folke/snacks.nvim",
  opts = function()
    local term = require("snacks.image.terminal")
    local detect = term._detect
    local nested ---@type boolean?
    term._detect = function(cb)
      detect(cb)
      if nested == nil then
        local outer = vim.env.TMUX and vim.fn.system({ "tmux", "display-message", "-p", "#{client_termname}" }) or ""
        nested = outer:find("^tmux") ~= nil or outer:find("^screen") ~= nil
      end
      if not nested then
        return
      end
      vim.env.SNACKS_GHOSTTY = vim.env.SNACKS_GHOSTTY or "1"
      local function wrap(data)
        return "\027Ptmux;" .. data:gsub("\027", "\027\027") .. "\027\\"
      end
      term.transform = function(data)
        return wrap(wrap(data))
      end
    end
  end,
}
