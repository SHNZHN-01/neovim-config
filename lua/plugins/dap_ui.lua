require("dapui").setup({
	controls = {
		element = "repl",
		enabled = false,
	},
	layouts = {
		{
			elements = {
				-- {
				--     id = "breakpoints",
				--     size = 0.10
				-- },
				{
					id = "stacks",
					size = 0.50,
				},
				{
					id = "scopes",
					size = 0.50,
				},
			},
			position = "left",
			size = 50,
		},
		{
			elements = {
				-- {
				--     id = "repl",
				--     size = 0.0
				-- },
				{
					id = "watches",
					size = 0.30,
				},
				{
					id = "console",
					size = 0.70,
				},
			},
			position = "bottom",
			size = 20,
		},
	},
})

local dap = require("dap")
local dapui = require("dapui")
dap.listeners.before.launch.dapui_config = function()
	dapui.open({})
end

local map = vim.keymap.set

map("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Continue" })
map("n", "<leader>dC", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
map("n", "<leader>dT", function()
	require("dap").terminate()
end, { desc = "Terminate" })
map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
map("n", "<leader>ddb", function()
	require("dapui").float_element("breakpoints", {
		width = 30,
		height = 15,
		enter = true,
		title = "",
		position = "center",
	})
end, { desc = "Show breakpoints window" })

map("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dL", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "Log point" })
map("n", "<leader>dp", function()
	require("dap").pause()
end, { desc = "Pause" })
map("n", "<leader>drr", function()
	require("dap").run_last()
end, { desc = "Run last" })
map("n", "<leader>ds", function()
	require("dap").step_back()
end, { desc = "Step back" })
map("n", "<leader>dg", function()
	require("dap").goto_()
end, { desc = "Drag execution to cursor" })
map("n", "<leader>dk", function()
	require("dap").up()
end, { desc = "Stack up" })
map("n", "<leader>dj", function()
	require("dap").down()
end, { desc = "Stack down" })
map("n", "<leader>dQ", function()
	require("dap").list_breakpoints()
end, { desc = "Breakpoints to quickfix" })
map("n", "<leader>dx", function()
	require("dap").clear_breakpoints()
end, { desc = "Clear breakpoints" })
map({ "n", "v" }, "<leader>de", function()
	require("dapui").eval()
end, { desc = "Eval expression" })
map("n", "<leader>dR", function()
	require("dap").repl.toggle()
end, { desc = "Toggle REPL" })
