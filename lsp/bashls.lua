return {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = { ".git" },
	settings = {
		bashIde = {
			-- files the server indexes for workspace symbols / go-to-definition
			globPattern = "**/*@(.sh|.inc|.bash|.command)",
		},
	},
}
