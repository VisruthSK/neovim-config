vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
	{ src = "https://github.com/Julian/lean.nvim" },
	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/OXY2DEV/markview.nvim" },
})
vim.cmd("packadd nvim.undotree")

require("catppuccin").setup({
	flavour = "mocha",

	color_overrides = {
		mocha = {
			base = "#000000",
			mantle = "#080808",
			crust = "#101010",
		},
	},
})
vim.cmd.colorscheme("catppuccin-mocha")

vim.g.lean_config = {
	mappings = true,
}

require("markview").setup({
	preview = {
		enable = true,
		enable_hybrid_mode = true,
		icon_provider = "mini",
	},
})

require("otter").setup()
require("quarto").setup({
	lspFeatures = {
		enabled = true,
		languages = { "r", "python", "julia", "bash" },

		diagnostics = {
			enabled = true,
			triggers = { "BufWritePost" },
		},

		completion = {
			enabled = true,
		},
	},
})

local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup({
	keymap = {
		preset = "default",
	},

	completion = {
		menu = {
			auto_show = false,
		},

		documentation = {
			auto_show = false,
		},
	},

	signature = {
		enabled = false,
	},

	sources = {
		default = { "lsp", "path" },
	},
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		yaml = { "yamark" },
		toml = { "taplo" },
		r = { "air" },
		python = { "ruff_format" },
		quarto = { "injected" },
	},

	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat then
			return
		end
		return {
			timeout_ms = 1000,
			lsp_format = "fallback",
		}
	end,

	formatters = {
		yamark = {
			command = "yamark",
			args = {
				"format",
				"--stdin-file-path",
				"$FILENAME",
			},
			stdin = true,
		},

		injected = {
			options = {
				lang_to_formatters = {
					yaml = {},
				},
			},
		},
	},
})
