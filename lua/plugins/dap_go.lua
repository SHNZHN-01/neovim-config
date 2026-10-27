require("dap-go").setup({})

vim.keymap.set("n", "<leader>dt", function()
	require("dap-go").debug_test()
end, { desc = "Debug test (Go)" })
vim.keymap.set("n", "<leader>dlt", function()
	require("dap-go").debug_last_test()
end, { desc = "Debug last test (Go)" })
