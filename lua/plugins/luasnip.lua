require("luasnip").setup({
	snip_env = {
		s = require("luasnip.nodes.snippet").S,
		sn = require("luasnip.nodes.snippet").SN,
		t = require("luasnip.nodes.textNode").T,
		f = require("luasnip.nodes.functionNode").F,
		i = require("luasnip.nodes.insertNode").I,
		c = require("luasnip.nodes.choiceNode").C,
		d = require("luasnip.nodes.dynamicNode").D,
		r = require("luasnip.nodes.restoreNode").R,
		l = require("luasnip.extras").lambda,
		rep = require("luasnip.extras").rep,
		p = require("luasnip.extras").partial,
		m = require("luasnip.extras").match,
		n = require("luasnip.extras").nonempty,
		dl = require("luasnip.extras").dynamic_lambda,
		fmt = require("luasnip.extras.fmt").fmt,
		fmta = require("luasnip.extras.fmt").fmta,
		conds = require("luasnip.extras.expand_conditions"),
		types = require("luasnip.util.types"),
		events = require("luasnip.util.events"),
		parse = require("luasnip.util.parser").parse_snippet,
		ai = require("luasnip.nodes.absolute_indexer"),
	},
})

require("luasnip.loaders.from_lua").lazy_load()

local map = vim.keymap.set

map("i", "<C-k>", function()
	require("luasnip").expand()
end, { desc = "Expand snippet" })
map({ "i", "s" }, "<C-l>", function()
	if require("luasnip").locally_jumpable(1) then
		require("luasnip").jump(1)
	end
end, { desc = "Next snippet node" })
map({ "i", "s" }, "<C-j>", function()
	if require("luasnip").locally_jumpable(-1) then
		require("luasnip").jump(-1)
	end
end, { desc = "Prev snippet node" })
map({ "i", "s" }, "<C-e>", function()
	if require("luasnip").choice_active() then
		require("luasnip").change_choice(1)
	end
end, { desc = "Next snippet choice" })
map({ "i", "s" }, "<C-S-e>", function()
	if require("luasnip").choice_active() then
		require("luasnip").change_choice(-1)
	end
end, { desc = "Prev snippet choice" })
map("n", "<leader>se", function()
	require("luasnip.loaders").edit_snippet_files()
end, { desc = "Edit snippet files" })
