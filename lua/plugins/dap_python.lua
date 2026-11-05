-- The adapter runs with the wrapper's Python with debugpy (neovim.nix);
-- the program with the project's Python (its venv, or python3 on PATH).
require("dap-python").setup(vim.env.NVIM_SHNZHN_DEBUGPY_PYTHON or "python3")

vim.keymap.set("n", "<leader>dtm", function()
	require("dap-python").test_method()
end, { desc = "Debug test method (Python)" })
vim.keymap.set("n", "<leader>dtc", function()
	require("dap-python").test_class()
end, { desc = "Debug test class (Python)" })
vim.keymap.set("v", "<leader>ds", function()
	require("dap-python").debug_selection()
end, { desc = "Debug selection (Python)" })
