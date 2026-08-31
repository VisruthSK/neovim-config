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

