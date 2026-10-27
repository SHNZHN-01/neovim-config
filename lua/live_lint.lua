-- Live buffer diagnostics for linters that have no language server (statix,
-- deadnix). Runs them on the buffer's current contents and publishes the
-- results into vim.diagnostic. Output parsing is shared with project_diagnostics.lua.

local parse = require("project_diagnostics").parse

local linters = {
	nix = {
		{ name = "statix", cmd = { "statix", "check", "-o", "errfmt", "--stdin" }, stdin = true },
		{ name = "deadnix", cmd = { "deadnix", "-o", "json" } }, -- no stdin mode: gets a temp copy
	},
}

local ns = {}
for _, list in pairs(linters) do
	for _, l in ipairs(list) do
		ns[l.name] = vim.api.nvim_create_namespace("live_lint." .. l.name)
	end
end

local function lint(buf)
	local ft = vim.bo[buf].filetype
	local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
	local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
	for _, l in ipairs(linters[ft] or {}) do
		if vim.fn.executable(l.cmd[1]) == 1 then
			local cmd, tmp = vim.list_extend({}, l.cmd), nil
			if not l.stdin then
				tmp = vim.fn.tempname() .. "." .. ft
				vim.fn.writefile(vim.split(text, "\n", { plain = true }), tmp, "b")
				table.insert(cmd, tmp)
			end
			local opts = { text = true, stdin = l.stdin and text or nil, cwd = dir ~= "" and vim.uv.fs_stat(dir) and dir or nil }
			vim.system(cmd, opts, function(res)
				vim.schedule(function()
					if tmp then
						os.remove(tmp)
					end
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end
					local diags = {}
					for _, it in ipairs(parse[l.name](res.stdout, "/")) do
						diags[#diags + 1] = {
							lnum = it.lnum - 1,
							col = it.col - 1,
							severity = vim.diagnostic.severity[it.type],
							message = it.text,
							source = l.name,
						}
					end
					vim.diagnostic.set(ns[l.name], buf, diags)
				end)
			end)
		end
	end
end

vim.api.nvim_create_autocmd({ "FileType", "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("live_lint", { clear = true }),
	callback = function(args)
		if linters[vim.bo[args.buf].filetype] then
			lint(args.buf)
		end
	end,
})
