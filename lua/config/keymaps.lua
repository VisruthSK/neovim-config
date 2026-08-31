local pick = require("mini.pick")

-- Find
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

vim.keymap.set("n", "<leader>fr", function()
	require("mini.extra").pickers.visit_paths()
end, { desc = "Recent files" })

-- Toggles
vim.keymap.set("n", "<leader>tm", "<cmd>Markview<cr>", {
	desc = "Toggle Markdown preview",
})

vim.keymap.set("n", "<leader>td", function()
	local enabled = not vim.diagnostic.is_enabled({ bufnr = 0 })
	vim.diagnostic.enable(enabled, { bufnr = 0 })
	vim.notify("Diagnostics " .. (enabled and "on" or "off"))
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<leader>tf", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "off" or "on"))
end, { desc = "Toggle autoformat" })

vim.keymap.set("n", "<leader>tn", "<cmd>NoNeckPain<CR>", {
	desc = "Toggle narrow column",
})

-- Git
vim.keymap.set("n", "<leader>go", function()
	MiniDiff.toggle_overlay()
end, { desc = "Git diff overlay" })

vim.keymap.set({ "n", "x" }, "<leader>gs", function()
	MiniGit.show_at_cursor()
end, { desc = "Git show at cursor" })

-- General

vim.keymap.set("n", "<leader>?", function()
	require("mini.extra").pickers.keymaps()
end, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>e", function()
	require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, { desc = "File explorer" })

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float()
end, {
	desc = "Show diagnostic",
})

vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", {
	desc = "Undo tree",
})

vim.keymap.set("n", "<leader>w", function()
	vim.b.disable_autoformat = true
	vim.cmd.write()
	vim.b.disable_autoformat = false
end, { desc = "Save without formatting" })
