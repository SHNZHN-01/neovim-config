local ap = require("nvim-autopairs")
ap.setup({})
ap.toggle()

vim.keymap.set("n", "<leader>apt", function()
	ap.toggle()
	if not ap.state.disabled then
		ap.force_attach()
	end
end, { desc = "Toggle nvim autopairs" })
