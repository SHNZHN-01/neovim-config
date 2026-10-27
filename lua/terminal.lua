-- Terminal (built-in :terminal, replaces nvterm)

local term_buf = nil

-- Find the window currently displaying the terminal buffer, if any.
local function term_window()
	if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == term_buf then
			return win
		end
	end
	return nil
end

-- Create the terminal buffer once, then keep it running in the background.
local function ensure_term_buf()
	if term_buf ~= nil and vim.api.nvim_buf_is_valid(term_buf) then
		return term_buf
	end
	local original = vim.api.nvim_get_current_buf()
	vim.cmd("terminal")
	term_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_set_current_buf(original) -- hide it, shell keeps running
	return term_buf
end

local function toggle_terminal(pos)
	local buf = ensure_term_buf()
	-- Already inside the terminal -> hide it.
	if vim.api.nvim_get_current_buf() == buf then
		vim.cmd("hide")
		return
	end
	local win = term_window()
	if win ~= nil then
		-- Terminal open elsewhere -> jump to it.
		vim.api.nvim_set_current_win(win)
	elseif pos == "horizontal" then
		vim.cmd("botright split")
		vim.api.nvim_set_current_buf(buf)
	elseif pos == "vertical" then
		vim.cmd("rightbelow vsplit")
		vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.4))
		vim.api.nvim_set_current_buf(buf)
	else -- float (matches your old nvterm geometry)
		vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			row = math.floor(vim.o.lines * 0.3),
			col = math.floor(vim.o.columns * 0.25),
			width = math.floor(vim.o.columns * 0.5),
			height = math.floor(vim.o.lines * 0.4),
			border = "single",
		})
	end
	vim.cmd("startinsert")
end

local map = vim.keymap.set

map({ "n", "t" }, "<A-h>", function()
	toggle_terminal("horizontal")
end, { desc = "Toggle horizontal terminal" })
map({ "n", "t" }, "<A-v>", function()
	toggle_terminal("vertical")
end, { desc = "Toggle vertical terminal" })
map({ "n", "t" }, "<A-i>", function()
	toggle_terminal("float")
end, { desc = "Toggle floating terminal" })

map("n", "<leader>tv", function()
	vim.cmd("vertical terminal " .. vim.fn.input({ prompt = "cmd: ", completion = "shellcmd" }))
end, { desc = "One-off vertical terminal" })
map("n", "<leader>tt", function()
	vim.cmd("tab terminal " .. vim.fn.input({ prompt = "cmd: ", completion = "shellcmd" }))
end, { desc = "One-off tab terminal" })

local term_grp = vim.api.nvim_create_augroup("terminal", { clear = true })

-- auto_insert: entering any terminal buffer drops you into insert mode
vim.api.nvim_create_autocmd("BufEnter", {
	group = term_grp,
	pattern = "term://*",
	callback = function()
		vim.cmd("startinsert")
	end,
})

-- hide (don't kill) hidden terminals, keep them out of buffer lists
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_grp,
	callback = function(ev)
		vim.bo[ev.buf].bufhidden = "hide"
		vim.bo[ev.buf].buflisted = false
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.signcolumn = "no"
	end,
})

-- close_on_exit equivalent
vim.api.nvim_create_autocmd("TermClose", {
	group = term_grp,
	callback = function(ev)
		vim.schedule(function()
			pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
		end)
	end,
})
