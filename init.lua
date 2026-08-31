vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.plugins")
require("config.mini")
require("config.lsp")
require("config.treesitter")
require("config.arf").setup()
require("config.keymaps")
