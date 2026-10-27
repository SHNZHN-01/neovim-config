require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		python = { "ruff_format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},

	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 500, lsp_format = "fallback" }
	end,
})

vim.api.nvim_create_user_command("FormatToggle", function(args)
	if args.bang then
		vim.b.disable_autoformat = not vim.b.disable_autoformat -- :FormatToggle! = this buffer
	else
		vim.g.disable_autoformat = not vim.g.disable_autoformat -- :FormatToggle  = global
	end
end, { bang = true })
