-- On this file go the keymaps that don't have a specific file
local map = vim.keymap.set

-- LaTeX (Nabla)

map("n", "<leader>lp", function()
	require("nabla").popup({ border = "rounded" })
end, { desc = "LaTeX popup" })
map("n", "<leader>lt", function()
	require("nabla").toggle_virt()
end, { desc = "Toggle LaTeX virtual text" })

-- Editor and buffers

map("t", "<C-w>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>ii", "gg=G<C-o>", { desc = "Indent whole buffer" })

-- Visual-mode movement

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Opencode

map({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode…" })
map({ "n", "x" }, "<leader>os", function()
	require("opencode").select()
end, { desc = "Select OpenCode…" })

map({ "n", "x" }, "<leader>o", function()
	return require("opencode").operator("@this ")
end, { desc = "Append range to OpenCode", expr = true })
map("n", "<leader>oo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Append line to OpenCode", expr = true })

map("n", "<S-C-u>", function()
	require("opencode").command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })
map("n", "<S-C-d>", function()
	require("opencode").command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })

-- Disable leader-prefixed keymaps inside the opencode buffer by shadowing
-- them with buffer-local <Nop> mappings.
-- Note: this only shadows maps that exist at FileType time; it is not a
-- general sandbox against maps created later.
local leader = vim.g.mapleader or "\\"
local prefixes = { leader, "<leader>" }
if leader == " " then
	table.insert(prefixes, "<Space>")
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("opencode-no-leader", { clear = true }),
	pattern = "opencode",
	callback = function(args)
		for _, mode in ipairs({ "n", "x", "s", "o", "i", "t", "c" }) do
			for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
				for _, prefix in ipairs(prefixes) do
					if keymap.lhs:sub(1, #prefix) == prefix then
						vim.keymap.set(mode, keymap.lhs, "<Nop>", { buffer = args.buf })
						break
					end
				end
			end
		end
	end,
})
