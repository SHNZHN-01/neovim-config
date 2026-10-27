require("neogen").setup({
	snippet_engine = "luasnip",
})

vim.keymap.set("n", "<leader>na", "<cmd>Neogen<cr>", { desc = "Annotate" })
vim.keymap.set("n", "<leader>nf", "<cmd>Neogen func<cr>", { desc = "Annotate function" })
vim.keymap.set("n", "<leader>nc", "<cmd>Neogen class<cr>", { desc = "Annotate class" })
vim.keymap.set("n", "<leader>nt", "<cmd>Neogen type<cr>", { desc = "Annotate type" })
vim.keymap.set("n", "<leader>nF", "<cmd>Neogen file<cr>", { desc = "Annotate file" })
