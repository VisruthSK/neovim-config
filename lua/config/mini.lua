require("mini.icons").setup()
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.files").setup()
require("mini.visits").setup()

require("mini.pairs").setup()
require("mini.ai").setup()
require("mini.surround").setup()

require("mini.diff").setup()
require("mini.git").setup()

require("mini.statusline").setup()

local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = { "n", "x" }, keys = "<Leader>" },

		-- `[` and `]` keys
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },

		-- `g` key
		{ mode = { "n", "x" }, keys = "g" },

		-- Marks
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },

		-- Registers
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = { "n", "x" }, keys = "z" },
	},

	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},

	window = {
		delay = 0,
	},
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		fixme = { pattern = "%f[%w]FIXME%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]HACK%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]TODO%f[%W]", group = "MiniHipatternsTodo" },
		hex = hipatterns.gen_highlighter.hex_color(),
	},
})
