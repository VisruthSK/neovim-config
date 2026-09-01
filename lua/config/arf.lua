local M = {}

local buf, job
local plot_win, plot_image
local watcher, view_pending

local run = vim.fn.stdpath("run")
local plot_file = vim.fs.joinpath(run, "arf-plot.png")
local plot_ready = vim.fs.joinpath(run, "arf-plot-ready")
local view_file = vim.fs.joinpath(run, "arf-view.csv")
local view_ready = vim.fs.joinpath(run, "arf-view-ready")

local function running()
	return job ~= nil
end

local function send(code)
	if not running() then
		vim.notify("Start arf with <leader>r", vim.log.levels.ERROR)
		return false
	end
	vim.api.nvim_chan_send(job, "\27[200~" .. code .. "\27[201~\r")
	return true
end

local function advance_after(line)
	local target = line + 1
	if target > vim.api.nvim_buf_line_count(0) then
		return
	end
	local text = vim.api.nvim_buf_get_lines(0, target - 1, target, false)[1]
	local col = text:find("%S")
	vim.api.nvim_win_set_cursor(0, { target, col and col - 1 or 0 })
end

-- Plotting relies on vim.ui.img (>0.13)
local function plot_opts()
	local pos = vim.fn.screenpos(plot_win, 1, 1)
	return {
		row = pos.row,
		col = pos.col,
		width = vim.api.nvim_win_get_width(plot_win),
		height = vim.api.nvim_win_get_height(plot_win),
		zindex = 10,
	}
end

local function show_plot()
	if not vim.uv.fs_stat(plot_file) then
		return
	end
	if not plot_win or not vim.api.nvim_win_is_valid(plot_win) then
		local plot_buf = vim.api.nvim_create_buf(false, true)
		plot_win = vim.api.nvim_open_win(plot_buf, false, {
			split = "right",
			win = -1,
			width = math.max(32, math.floor(vim.o.columns * 0.4)),
			style = "minimal",
		})
	end
	if plot_image then
		vim.ui.img.del(plot_image)
	end
	plot_image = vim.ui.img.set(vim.fn.readblob(plot_file), plot_opts())
end

local function open_view()
	local view_buf = vim.api.nvim_create_buf(false, true)
	local tab = vim.api.nvim_open_tabpage(view_buf, true, {})
	local win = vim.api.nvim_tabpage_get_win(tab)

	local id = vim.fn.jobstart({
		"nu",
		"-c",
		"open $env.NVIM_ARF_VIEW | explore -i",
	}, {
		term = true,
		env = {
			NVIM_ARF_VIEW = view_file,
		},
		on_exit = function()
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end)
		end,
	})

	if id <= 0 then
		vim.api.nvim_win_close(win, true)
		vim.notify("Failed to start Nushell", vim.log.levels.ERROR)
		return
	end

	vim.cmd.startinsert()
end

local function start_watcher()
	watcher = assert(vim.uv.new_fs_event())
	watcher:start(
		run,
		{},
		vim.schedule_wrap(function(err, name)
			if err or not name then
				return
			end
			if name == "arf-plot-ready" then
				show_plot()
			elseif name == "arf-view-ready" and view_pending then
				view_pending = false
				open_view()
			end
		end)
	)
end

function M.toggle()
	if running() and buf and vim.api.nvim_buf_is_valid(buf) then
		local win = vim.fn.bufwinid(buf)
		if win ~= -1 then
			vim.api.nvim_win_close(win, true)
		else
			vim.cmd("botright 12split")
			vim.api.nvim_win_set_buf(0, buf)
			vim.cmd.startinsert()
		end
		return
	end

	vim.cmd("botright 12new")
	buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].bufhidden = "hide"
	job = vim.fn.jobstart({ "arf" }, {
		term = true,
		cwd = vim.fn.getcwd(),
		env = {
			NVIM_ARF_PLOT = plot_file,
			NVIM_ARF_PLOT_READY = plot_ready,
			NVIM_ARF_VIEW = view_file,
			NVIM_ARF_VIEW_READY = view_ready,
		},
		on_exit = function(id)
			if job == id then
				job = nil
			end
		end,
	})
	if job <= 0 then
		job = nil
		vim.notify("Failed to start arf", vim.log.levels.ERROR)
		return
	end
	vim.cmd.startinsert()
end

function M.statement()
	local node = vim.treesitter.get_node({ ignore_injections = false })
	if not node or node:type() == "program" then
		local line = vim.api.nvim_win_get_cursor(0)[1]
		if send(vim.api.nvim_get_current_line()) then
			advance_after(line)
		end
		return
	end
	while node:parent() and node:parent():type() ~= "program" do
		node = node:parent()
	end
	local _, _, end_row, end_col = node:range()
	local last_line = end_col == 0 and end_row or end_row + 1
	if send(vim.treesitter.get_node_text(node, 0)) then
		advance_after(last_line)
	end
end

function M.selection()
	local a, b = vim.fn.getpos("v"), vim.fn.getpos(".")
	local lines = vim.fn.getregion(a, b, { type = vim.fn.mode() })
	local last_line = math.max(a[2], b[2])
	local win = vim.api.nvim_get_current_win()
	if send(table.concat(lines, "\n")) then
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_cursor(win, {
					math.min(last_line + 1, vim.api.nvim_buf_line_count(0)),
					0,
				})
			end
		end)
	end
	return "<Esc>"
end

function M.view(expr)
	if not running() then
		vim.notify("Start arf with <leader>r", vim.log.levels.ERROR)
		return
	end
	view_pending = true
	pcall(vim.uv.fs_unlink, view_ready)
	send((".nvim_view((%s))"):format(expr))
end

function M.setup()
	start_watcher()
	vim.keymap.set("n", "<leader>r", M.toggle, { desc = "R console" })

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
			vim.keymap.set("n", "<leader>v", function()
				local node = vim.treesitter.get_node({ ignore_injections = false })
				M.view(node and vim.treesitter.get_node_text(node, 0) or vim.fn.expand("<cword>"))
			end, { buffer = ev.buf, desc = "View R object" })
			vim.keymap.set("x", "<leader>v", function()
				local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
				M.view(table.concat(lines, "\n"))
				return "<Esc>"
			end, {
				buffer = ev.buf,
				expr = true,
				replace_keycodes = true,
				desc = "View R selection",
			})
		end,
	})

	vim.api.nvim_create_autocmd("WinResized", {
		callback = function()
			if plot_image and plot_win and vim.api.nvim_win_is_valid(plot_win) then
				vim.ui.img.set(plot_image, plot_opts())
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(ev)
			if tonumber(ev.match) == plot_win then
				if plot_image then
					vim.ui.img.del(plot_image)
				end
				plot_win, plot_image = nil, nil
			end
		end,
	})
end

return M
