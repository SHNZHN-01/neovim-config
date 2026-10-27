require("gitsigns").setup({
	signcolumn = false,
})

vim.keymap.set("n", "<leader>tgs", "<cmd>Gitsigns toggle_signs<cr>", { desc = "Toggle Gitsigns" })
