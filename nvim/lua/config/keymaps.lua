vim.keymap.set("n", "<C-d>", "10jjzz", { silent = true })
vim.keymap.set("n", "<C-u>", "10kkzz", { silent = true })
vim.keymap.set("n", "<C-m>", "10jjzz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-,>", "10kkzz", { noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>e",
  "<CMD>lua require('oil').toggle_float()<CR>",
  { desc = "Open parent directory", noremap = true, silent = true }
)

-- vim.keymap.set(
--   "n",
--   "<leader>e",
--   ":NvimTreeToggle<CR>",
--   { desc = "Open parent directory", noremap = true, silent = true }
-- )
vim.keymap.set("n", "P", "o<esc>p", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>nn", "<cmd>NoiceDismiss <cr>", { desc = "Dismiss Notifications" })
vim.keymap.set("n", "<leader>sl", "<cmd>vsplit<cr>", { desc = "Split right" })
vim.keymap.set("n", "<leader>sj", "<cmd>split<cr>", { desc = "Split below" })
vim.keymap.set("n", "<leader>wj", "<cmd>close<cr>", { desc = "Close window" })
vim.keymap.set("n", "<CR>", "o<Esc>")
-- Removing default LazyVim keymaps
vim.keymap.del("n", "<leader>gG")
-- vim.keymap.del("n", "<C-d>")

vim.keymap.del("n", "<C-F>")
vim.keymap.del("n", "<leader>un")
vim.keymap.del("n", "<leader>xx")
vim.keymap.del("n", "<leader>sna")
vim.keymap.del("n", "<C-t>")
vim.keymap.del({ "n", "x" }, "y")
vim.keymap.set({ "n", "v" }, "c", '"_c', { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "x", '"_x', { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<c-t>", "<cmd>Trouble diagnostics toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", "<cmd>GrugFar<cr>", { desc = "Search/Replace" })

vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")

vim.keymap.del("n", "H")
vim.keymap.del("n", "L")
vim.keymap.set("n", "H", require("arrow.persist").previous)
vim.keymap.set("n", "L", require("arrow.persist").next)

-- cheerio schema format macro

vim.api.nvim_create_user_command("ToggleSchemaFormat", function()
  -- Get the start and end positions of the visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Get the selected lines as a block of text
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  -- Join the lines into a single string to check for opening/closing braces
  local full_text = table.concat(lines, "\n")

  -- Detect if the block contains a long-form schema (i.e., contains '{' and '}')
  local isLongForm = full_text:match("{.*}") ~= nil

  local transformed = {}

  if isLongForm then
    -- Collapse long form to short form

    for i, line in ipairs(lines) do
      local key = line:match("^%s*(%w+)%s*:%s*{")
      if key and lines[i + 1] and lines[i + 1]:match("selector:%s*['\"](.-)['\"]") then
        local selector = lines[i + 1]:match("selector:%s*['\"](.-)['\"]")
        table.insert(transformed, key .. ": '" .. selector .. "',")
        break
      end
    end
  else
    -- Expand short form to long form
    for _, line in ipairs(lines) do
      local key, selector = string.match(line, "^%s*(%w+)%s*:%s*['\"](.-)['\"]")
      if key and selector then
        table.insert(transformed, key .. ": {")
        table.insert(transformed, "  selector: '" .. selector .. "',")
        table.insert(
          transformed,
          "  value: (el: Element | undefined) => $(el).text().match(/(<=)[ :]+(w+)?/i)?.[1] ?? '',"
        )
        table.insert(transformed, "},")
        break
      end
    end
  end

  -- vim.notify("Transformed:\n" .. table.concat(transformed, "\n"), vim.log.levels.INFO)
  -- Calculate the number of lines that should be replaced in the buffer
  local num_lines_to_replace = #transformed
  local num_lines_in_range = end_pos[2] - start_pos[2] + 1
  vim.fn.setline(start_pos[2], { unpack(transformed, 1, num_lines_in_range) })

  if num_lines_to_replace > num_lines_in_range then
    local extra_lines = { unpack(transformed, num_lines_in_range + 1, num_lines_to_replace) }
    vim.fn.append(end_pos[2], extra_lines)
  else
    vim.api.nvim_buf_set_lines(0, start_pos[2], start_pos[2] + 6, false, {})
  end
end, { range = true })

-- Keybind in visual mode
vim.keymap.set("v", "<leader>cj", [[:'<,'>ToggleSchemaFormat<CR>]], {
  noremap = true,
  silent = true,
  desc = "Toggle Cheerio schema format",
})
