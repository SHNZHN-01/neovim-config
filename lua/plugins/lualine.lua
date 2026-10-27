require("lualine").setup({
	options = {
		theme = "auto",
		ignore_focus = {
			"dapui_watches",
			"dapui_breakpoints",
			"dapui_scopes",
			"dapui_console",
			"dapui_stacks",
			"dap-repl",
			"NvimTree",
		},
		globalstatus = true,
		sections = {
			lualine_z = {
				{
					-- Shows the currently connected server and its status
					require("opencode").statusline,
				},
			},
		},
	},
})
