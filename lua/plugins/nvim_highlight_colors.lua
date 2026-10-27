local h_colors = require("nvim-highlight-colors")
h_colors.setup({})
h_colors.turnOff()

vim.keymap.set("n", "<leader>hct", function()
	h_colors.toggle()
end, { desc = "Toggle Highlight Colors" })
