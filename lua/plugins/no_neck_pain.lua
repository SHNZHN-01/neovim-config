require("no-neck-pain").setup({
	width = 125,
})
require("no-neck-pain").enable()

vim.keymap.set("n", "<leader>nn", "<cmd>NoNeckPain<cr>", { desc = "Toggle NoNeckPain" })
vim.keymap.set("n", "<leader>nnu", "<cmd>NoNeckPainWidthUp<cr>", { desc = "Increase width of NoNeckPain" })
vim.keymap.set("n", "<leader>nnd", "<cmd>NoNeckPainWidthDown<cr>", { desc = "Decrease width of NoNeckPain" })
