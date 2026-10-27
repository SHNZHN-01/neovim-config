-- vim.opt.rtp:prepend(vim.fn.expand("<sfile>:p:h"))
vim.cmd.colorscheme("mycolorscheme")

vim.o.winborder = "rounded"
vim.o.pumheight = 15

vim.diagnostic.config({
	underline = false,
	virtual_text = {
		format = function(diagnostic)
			if diagnostic.severity == vim.diagnostic.severity.ERROR then
				return string.format(" '%s", diagnostic.message)
			elseif diagnostic.severity == vim.diagnostic.severity.WARN then
				return string.format("! '%s", diagnostic.message)
			elseif diagnostic.severity == vim.diagnostic.severity.INFO then
				return string.format("i '%s", diagnostic.message)
			elseif diagnostic.severity == vim.diagnostic.severity.HINT then
				return string.format("? '%s", diagnostic.message)
			else
				return diagnostic.message
			end
		end,
		prefix = "",
	},
	signs = false,
	update_in_insert = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = false,
		header = "",
		prefix = "",
	},
})
