local ts = require("nvim-treesitter")

ts.install({
	"lua",
	"rust",
	"python",
	"r",
	"markdown",
	"markdown_inline",
	"yaml",
	"toml",
	"bash",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"rust",
		"python",
		"r",
		"markdown",
		"quarto",
		"yaml",
		"toml",
		"bash",
	},
	callback = function()
		vim.treesitter.start()
	end,
})
