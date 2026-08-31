local ts = require("nvim-treesitter")

local parsers = {
	"lua",
	"rust",
	"python",
	"r",
	"markdown",
	"markdown_inline",
	"yaml",
	"toml",
	"bash",
	"typst",
}

ts.install(parsers)

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"rust",
		"python",
		"r",
		"markdown",
		"yaml",
		"toml",
		"sh",
		"typst",
	},
	callback = function()
		vim.treesitter.start()
	end,
})
