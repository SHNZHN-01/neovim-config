-- Highlighting + indent (main branch: no module system, enable per buffer)
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

require("nvim-treesitter-textobjects").setup({
	select = { lookahead = true },
	move = { set_jumps = true },
})

local select = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")
local swap = require("nvim-treesitter-textobjects.swap")

local selects = {
	aa = "@parameter.outer",
	ia = "@parameter.inner",
	af = "@function.outer",
	["if"] = "@function.inner",
	ac = "@class.outer",
	ic = "@class.inner",
	ai = "@conditional.outer",
	ii = "@conditional.inner",
	al = "@loop.outer",
	il = "@loop.inner",
	ak = "@block.outer",
	ik = "@block.inner",
	is = "@statement.inner",
	as = "@statement.outer",
	ad = "@comment.outer",
	am = "@call.outer",
	im = "@call.inner",
}
for lhs, query in pairs(selects) do
	vim.keymap.set({ "x", "o" }, lhs, function()
		select.select_textobject(query, "textobjects")
	end, { desc = "TS select " .. query })
end

local moves = {
	goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
	goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
	goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
	goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
}
for fn, maps in pairs(moves) do
	for lhs, query in pairs(maps) do
		vim.keymap.set({ "n", "x", "o" }, lhs, function()
			move[fn](query, "textobjects")
		end, { desc = "TS " .. fn .. " " .. query })
	end
end

vim.keymap.set("n", ")a", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap with next parameter" })
vim.keymap.set("n", ")A", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap with previous parameter" })
