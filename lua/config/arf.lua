local M = {}

local buf
local job

local function running()
	return job and vim.fn.jobwait({ job }, 0)[1] == -1
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
	local node = vim.treesitter.get_node()

	if not node or node:type() == "program" then
		send(vim.api.nvim_get_current_line())
		return
	end

	while node:parent() and node:parent():type() ~= "program" do
		node = node:parent()
	end

	send(vim.treesitter.get_node_text(node, 0))
end

function M.selection()
	local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })

	send(table.concat(lines, "\n"))
end

function M.setup()
	vim.keymap.set("n", "<leader>r", M.toggle, {
		desc = "R console",
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "r",

		callback = function(ev)
			vim.keymap.set("n", "<C-CR>", M.statement, {
				buffer = ev.buf,
				desc = "Run R expression",
			})

			vim.keymap.set("x", "<C-CR>", M.selection, {
				buffer = ev.buf,
				desc = "Run R selection",
			})
		end,
	})
end

return M
