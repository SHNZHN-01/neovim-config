require("ibl").setup({
	enabled = false,
	exclude = {
		filetypes = { "NvimTree" },
	},
})

vim.keymap.set("n", "<leader>ibt", "<cmd>IBLToggle<cr>", { desc = "Toggle indent blankline" })
