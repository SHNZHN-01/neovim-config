require("nvterm").setup({
	terminals = {
		shell = vim.o.shell,
		list = {},
		type_opts = {
			vertical = {
				location = "rightbelow",
				split_ratio = 0.4,
			},
			float = {
				relative = "editor",
				row = 0.3,
				col = 0.25,
				width = 0.5,
				height = 0.4,
				border = "single",
			},
		},
	},
	behavior = {
		autoclose_on_quit = {
			enable = false,
			confirm = true,
		},
		close_on_exit = true,
		auto_insert = true,
	},
})
