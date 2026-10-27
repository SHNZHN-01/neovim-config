return {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
	-- ty owns hover; ruff's hover only documents noqa codes.
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
}
