require("git-conflict").setup({})

vim.keymap.set("n", "<leader>gq", "<cmd>GitConflictListQf<cr>", { desc = "Git conflicts to quickfix" })
