local ts = require("nvim-treesitter")

local filetypes = {
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

ts.install(filetypes)

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function()
		vim.treesitter.start()
	end,
})
