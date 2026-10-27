local telescope = require("telescope")

telescope.setup({
	extensions = {
		file_browser = {
			initial_mode = "normal",
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
			hijack_netrw = true,
		},
		fzf = {},
	},
	defaults = {
		initial_mode = "normal",
		preview_title = false,
		prompt_title = false,
		results_title = false,
		dynamic_preview_title = false,
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--ignore-file",
			".gitignore",
		},
	},
	pickers = {
		git_files = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		live_grep = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		help_tags = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		lsp_references = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		lsp_document_symbols = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		diagnostics = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		commands = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
		},
		find_files = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
			hidden = hidden,
			file_ignore_patterns = {
				"^.git/",
				"node_modules",
			},
		},
		buffers = {
			preview_title = false,
			prompt_title = false,
			results_title = false,
			dynamic_preview_title = false,
			show_all_buffers = true,
			sort_lastused = true,
			theme = "dropdown",
			previewer = false,
			mappings = {
				i = {
					["<C-d>"] = "delete_buffer",
				},
			},
		},
	},
})

telescope.load_extension("file_browser")
telescope.load_extension("fzf")

local map = vim.keymap.set

map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fgf", function()
	require("telescope.builtin").git_files()
end, { desc = "Find git files" })
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Buffers" })
map("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Help tags" })
map("n", "<leader>fdb", function()
	require("telescope.builtin").diagnostics({ bufnr = 0 })
end, { desc = "Diagnostics (current buffer)" })
map("n", "<leader>fdo", function()
	require("telescope.builtin").diagnostics({ no_unlisted = true })
end, { desc = "Diagnostics (open buffers)" })
map("n", "<leader>fdw", function()
	require("project_diagnostics").workspace()
end, { desc = "Diagnostics (workspace)" })
map("n", "<leader>fr", function()
	require("telescope.builtin").lsp_references()
end, { desc = "References" })
map("n", "<leader>fs", function()
	require("telescope.builtin").lsp_document_symbols()
end, { desc = "Document symbols" })
map("n", "<leader>fc", function()
	require("telescope.builtin").commands()
end, { desc = "Commands" })
map("n", "<leader>ps", function()
	require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Grep with prompt" })
map("n", "<leader>tf", function()
	require("telescope").extensions.file_browser.file_browser()
end, { desc = "File browser" })
map("n", "<leader>tt", function()
	require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true })
end, { desc = "File browser (current buffer dir)" })
map("n", "<leader>ms", function()
	require("telescope.builtin").keymaps()
end, { desc = "Show mappings" })
map("n", "<leader>fR", function()
	require("telescope.builtin").resume()
end, { desc = "Resume last picker" })
map("n", "<leader>f/", function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Fuzzy find in buffer" })
map("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end, { desc = "Old files" })
map("n", "<leader>gs", function()
	require("telescope.builtin").git_status()
end, { desc = "Git status" })
map("n", "<leader>gc", function()
	require("telescope.builtin").git_commits()
end, { desc = "Git commits" })
map("n", "<leader>gb", function()
	require("telescope.builtin").git_branches()
end, { desc = "Git branches" })
map("n", "<leader>gS", function()
	require("telescope.builtin").git_stash()
end, { desc = "Git stash" })
map("n", "<leader>f'", function()
	require("telescope.builtin").marks()
end, { desc = "Marks" })
map("n", '<leader>f"', function()
	require("telescope.builtin").registers()
end, { desc = "Registers" })
map("n", "<leader>fj", function()
	require("telescope.builtin").jumplist()
end, { desc = "Jumplist" })
map("n", "<leader>f;", function()
	require("telescope.builtin").command_history()
end, { desc = "Command history" })
map("n", "<leader>f?", function()
	require("telescope.builtin").search_history()
end, { desc = "Search history" })
map("n", "<leader>fz", function()
	require("telescope.builtin").spell_suggest()
end, { desc = "Spell suggest" })
map("n", "<leader>fM", function()
	require("telescope.builtin").man_pages()
end, { desc = "Man pages" })
map("n", "<leader>fp", function()
	require("telescope.builtin").pickers()
end, { desc = "Picker of pickers" })
