vim.lsp.config("harper_ls", {
	settings = {
		["harper-ls"] = {
			diagnosticSeverity = "warning",

			linters = {
				Dashes = false,
				NumericRangeEnDash = false,
			},
		},
	},
})

vim.lsp.config("r_language_server", {
	settings = {
		r = {
			lsp = {
				server_capabilities = {
					documentFormattingProvider = false,
					documentRangeFormattingProvider = false,
					documentOnTypeFormattingProvider = false,
				},
			},
		},
	},
})

vim.lsp.enable({
	"rust_analyzer",
	"r_language_server",
	"air",
	"harper_ls",
	"nu",
})
