local pick = require("mini.pick")

vim.keymap.set("n", "<leader>ff", function()
  pick.builtin.files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  pick.builtin.grep_live()
end, { desc = "Grep" })

vim.keymap.set("n", "<leader>fb", function()
  pick.builtin.buffers()
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>fh", function()
  pick.builtin.help()
end, { desc = "Help" })

vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "Files" })

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
  desc = "Code action",
})

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float()
end, {
  desc = "Show diagnostic",
})

vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", {
  desc = "Undo tree",
})

vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })

