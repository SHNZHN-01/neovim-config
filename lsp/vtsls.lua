-- JavaScript and TypeScript: types, completion, go-to-definition, renames.
-- vtsls wraps VS Code's TypeScript support. It bundles TypeScript and uses
-- the project's own (node_modules/typescript) when the project has one.
local inlayHints = {
	parameterNames = { enabled = "literals" },
	parameterTypes = { enabled = true },
	variableTypes = { enabled = true },
	propertyDeclarationTypes = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
	enumMemberValues = { enabled = true },
}

return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	settings = {
		vtsls = { autoUseWorkspaceTsdk = true },
		-- shown with <leader>ch (lsp.lua)
		typescript = { inlayHints = inlayHints },
		javascript = { inlayHints = inlayHints },
	},
}
