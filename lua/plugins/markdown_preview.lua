vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_browser = "firefox"

vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Start Markdown Preview" })
vim.keymap.set("n", "<leader>mps", "<cmd>MarkdownPreviewStop<cr>", { desc = "Stop Markdown Preview" })
vim.keymap.set("n", "<leader>mpt", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Preview" })
