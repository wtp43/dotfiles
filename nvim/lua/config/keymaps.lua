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
