local cmp = require("cmp")

cmp.setup({
	select_behavior = cmp.SelectBehavior.Select,
	mapping = cmp.mapping.preset.insert({}),
	view = {
		-- disable docs from opening automatically when selecting an item
		docs = {
			auto_open = false,
		},
	},
	-- We must specify a snippet engine, we chose luasnip (LuaSnip and cmp_luasnip)
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {
		completion = {
			border = "rounded",
		},
		documentation = {
			border = "rounded",
		},
		-- completion = cmp.config.window.bordered({ scrollbar = false }),
		-- documentation = cmp.config.window.bordered({ scrollbar = false }),
	},
	preselect = cmp.PreselectMode.None,
	-- completion = {
	--    autocomplete = false,
	sources = cmp.config.sources({
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "nvim_lua" },
	}, {
		{ name = "buffer" },
	}),
})

-- `/` cmdline setup.
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
	matching = { disallow_symbol_nonprefix_matching = false },
})

local map = vim.keymap.set

local function cmp_select()
	return { behavior = require("cmp").SelectBehavior.Select }
end

map("i", "<C-p>", function()
	require("cmp").select_prev_item(cmp_select())
end, { desc = "Select previous completion item" })
map("i", "<C-n>", function()
	require("cmp").select_next_item(cmp_select())
end, { desc = "Select next completion item" })
map("i", "<C-y>", function()
	require("cmp").confirm({ behavior = require("cmp").ConfirmBehavior.Insert, select = true })
end, { desc = "Confirm completion" })
map("i", "<C-s>", function()
	require("cmp").complete({
		config = {
			sources = {
				{ name = "luasnip" },
			},
		},
	})
end, { desc = "Complete snippet" })
map("i", "<C-g>", function()
	if cmp.visible_docs() then
		cmp.close_docs()
	else
		cmp.open_docs()
	end
end, { desc = "Toggle completion docs" })
