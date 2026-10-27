-- This file lives at <config>/lsp/emmylua_ls.lua; in the Nix wrapper that's the
-- ${src} store copy of the config, which is also on the runtimepath. Leaving it
-- out of the library stops the workspace being loaded twice when editing the config.
local src = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))

-- Every runtimepath entry's lua/ directory: $VIMRUNTIME (the vim.* API and its
-- type annotations) plus each plugin. Library roots are where require() names
-- start, so "telescope.builtin" resolves to <plugin>/lua/telescope/builtin.lua.
local library = {}
for _, dir in ipairs(vim.api.nvim_list_runtime_paths()) do
	dir = vim.fs.normalize(dir)
	local lua = dir .. "/lua"
	local stat = vim.uv.fs_stat(lua)
	if dir ~= src and stat and stat.type == "directory" then
		library[#library + 1] = lua
	end
end

return {
	cmd = { "emmylua_ls" },
	filetypes = { "lua" },
	root_markers = { ".emmyrc.json", ".emmyrc.lua", ".luarc.json", ".git" },
	settings = {
		-- emmylua_ls reads Neovim's settings under "Lua" or "emmylua", in the same
		-- schema as .emmyrc.json. project_diagnostics.lua reuses this table.
		emmylua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				library = library,
				-- Neovim-style projects require modules relative to lua/, not the repo root.
				workspaceRoots = { "${workspaceFolder}/lua" },
			},
			diagnostics = { globals = { "vim" } },
		},
	},
}
