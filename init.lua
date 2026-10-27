require("options")
require("appearance")
require("project_diagnostics")
require("live_lint")
require("keymaps")

for _, f in ipairs(vim.api.nvim_get_runtime_file("lua/plugins/*.lua", true)) do
	local name = f:match("([^/\\]+)%.lua$")
	if name then
		require("plugins." .. name)
	end
end

-- Loaded after plugins/telescope.lua so the terminal <leader>tt wins.
require("terminal")
