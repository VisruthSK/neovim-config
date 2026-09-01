local M = {}

local buf
local job

local function running()
	return job and vim.fn.jobwait({ job }, 0)[1] == -1
end

local function advance_after(line)
	local target = line + 1
	local count = vim.api.nvim_buf_line_count(0)

	if target > count then
		return
	end

	local text = vim.api.nvim_buf_get_lines(0, target - 1, target, false)[1]
	local col = text:find("%S")

	vim.api.nvim_win_set_cursor(0, {
		target,
		col and col - 1 or 0,
	})
end

local function send(code)
	if not running() then
		vim.notify("Start arf with <leader>r", vim.log.levels.ERROR)
		return
	end

	-- Bracketed paste keeps multiline R expressions together.
	vim.api.nvim_chan_send(job, "\27[200~" .. code .. "\27[201~\r")
end

function M.toggle()
	if running() and vim.api.nvim_buf_is_valid(buf) then
		local win = vim.fn.bufwinid(buf)

		if win ~= -1 then
			vim.api.nvim_win_close(win, true)
		else
			vim.cmd("botright 12split")
			vim.api.nvim_win_set_buf(0, buf)
			vim.cmd("startinsert")
		end

		return
	end

	vim.cmd("botright 12new")

	buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].bufhidden = "hide"

	job = vim.fn.jobstart({ "arf" }, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function()
			job = nil
		end,
	})

	vim.cmd("startinsert")
end

function M.statement()
	local node = vim.treesitter.get_node({
		ignore_injections = false,
	})

	if not node or node:type() == "program" then
		local line = vim.api.nvim_win_get_cursor(0)[1]

		send(vim.api.nvim_get_current_line())
		advance_after(line)

		return
	end

	while node:parent() and node:parent():type() ~= "program" do
		node = node:parent()
	end

	local _, _, end_row, end_col = node:range()

	-- Tree-sitter end positions are exclusive.
	local last_line = end_col == 0 and end_row or end_row + 1

	send(vim.treesitter.get_node_text(node, 0))
	advance_after(last_line)
end

function M.selection()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local mode = vim.fn.mode()

	local lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
	local last_line = math.max(start_pos[2], end_pos[2])
	local win = vim.api.nvim_get_current_win()

	send(table.concat(lines, "\n"))

	vim.schedule(function()
		if not vim.api.nvim_win_is_valid(win) then
			return
		end

		local target = math.min(last_line + 1, vim.api.nvim_buf_line_count(0))

		vim.api.nvim_win_set_cursor(win, { target, 0 })
	end)

	return "<Esc>"
end

function M.setup()
	vim.keymap.set("n", "<leader>r", M.toggle, {
		desc = "R console",
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "r", "quarto" },

		callback = function(ev)
			vim.keymap.set({ "n", "i" }, "<C-CR>", M.statement, {
				buffer = ev.buf,
				desc = "Run R expression",
			})

			vim.keymap.set("x", "<C-CR>", M.selection, {
				buffer = ev.buf,
				expr = true,
				replace_keycodes = true,
				desc = "Run R selection",
			})
		end,
	})
end

return M
