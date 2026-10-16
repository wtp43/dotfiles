-- An "icon" heading with an empty icon conceals the `#` markers and draws nothing.
local function heading(level)
  return { style = "icon", icon = "", sign = "", hl = "MarkviewHeading" .. level }
end

return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- Recommended
  enabled = false,
  dependencies = {
    "saghen/blink.cmp",
  },
  opts = {
    markdown = {
      headings = {
        shift_width = 0,
        heading_1 = heading(1),
        heading_2 = heading(2),
        heading_3 = heading(3),
        heading_4 = heading(4),
        heading_5 = heading(5),
        heading_6 = heading(6),
      },
    },
  },
}
