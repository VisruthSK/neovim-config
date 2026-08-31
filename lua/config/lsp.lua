vim.lsp.config("harper_ls", {
	settings = {
		["harper-ls"] = {
			diagnosticSeverity = "hint",
			linters = {
				Dashes = false,
				NumericRangeEnDash = false,
				LongSentences = false,
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
	"harper_ls",
	"nu",
})
