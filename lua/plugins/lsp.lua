-- Capabilities: advertise cmp's enhanced completion to every server.
-- Applied to the "*" wildcard config so it merges into all servers.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- Enable the servers. Each name must resolve to a binary on PATH (provided
-- via the wrapper's --prefix PATH in neovim.nix) and to an `lsp/<name>.lua`
-- definition in this config's `lsp/` directory.
vim.lsp.enable({
	"nixd",
	"clangd",
	"emmylua_ls",
	"ty",
	"ruff",
	"bashls",
})

local map = vim.keymap.set

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Diagnostics

map("n", "<leader>dr", function()
	vim.diagnostic.reset()
end, { desc = "Reset diagnostics" })

-- Use formatters declared in the "conform" config by default.
-- We fallback to LSP formatting if we don't have a formatter
-- declared for the specific language on "conform".
-- For example, "pyright" lsp does not support `textDocument/formatting`
-- So we need to add the "ruff" formatter which is not an lsp.
map("n", "<leader>fm", function()
	require("conform").format({ lsp_fallback = true, async = false })
end, { desc = "Format buffer" })

map("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
map("n", "<leader>cs", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })

map("n", "<leader>ch", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

map("n", "<leader>cc", function()
	vim.lsp.codelens.refresh()
	vim.lsp.codelens.run()
end, { desc = "Run codelens" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })

map("n", "<leader>dv", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_lines = not cfg.virtual_lines })
end, { desc = "Toggle diagnostic virtual lines" })

map("n", "<leader>cH", vim.lsp.buf.document_highlight, { desc = "Highlight references" })
map("n", "<leader>cC", vim.lsp.buf.clear_references, { desc = "Clear references" })

map("n", "<leader>cR", "<cmd>LspRestart<cr>", { desc = "LSP restart" })
map("n", "<leader>cS", "<cmd>LspStop<cr>", { desc = "LSP stop" })
map("n", "<leader>cA", "<cmd>LspStart<cr>", { desc = "LSP start" })
map("n", "<leader>cK", "<cmd>checkhealth lsp<cr>", { desc = "LSP checkhealth" })

map("n", "<leader>dl", function()
	require("project_diagnostics").lua()
end, { desc = "Project wide Lua diagnostics" })

map("n", "<leader>dp", function()
	require("project_diagnostics").python()
end, { desc = "Project wide Python diagnostics" })

map("n", "<leader>dn", function()
	require("project_diagnostics").nix()
end, { desc = "Project wide Nix diagnostics" })

map("n", "<leader>dc", function()
	require("project_diagnostics").clang_tidy()
end, { desc = "Project wide clang-tidy diagnostics" })
