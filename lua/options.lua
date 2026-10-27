-- vim.o.winborder = "rounded"
-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Interface options
--------------------
-- Hide "press ENTER" message
-- vim.opt.messagesopt = "wait:0,history:1000"
-- Hide commandline
-- vim.opt.cmdheight = 0
-- Set cursor to block
vim.opt.guicursor = ""
-- Show sign column yes or no
vim.opt.signcolumn = "auto:2"
-- Show line numbers
vim.opt.nu = true
vim.opt.relativenumber = true
-- Enable text wrapping
vim.opt.wrap = true
-- Set scroll offset (lines visible above/below cursor)
vim.opt.scrolloff = 8
-- Hide intro message
vim.opt.shortmess = "I"
-- Show character column marker
vim.opt.cc = "120"
-- termguicolors
vim.opt.termguicolors = true

-- Editor behavior
-----------------
-- Tab settings
vim.opt.tabstop = 4 -- Number of spaces a tab counts for
vim.opt.softtabstop = 4 -- Number of spaces inserted when pressing tab
vim.opt.shiftwidth = 4 -- Number of spaces for indentation
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = false -- Smart autoindentation

-- File handling
---------------
vim.opt.swapfile = false
vim.opt.backup = false

-- Search behavior
-----------------
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Clipboard
-----------------
vim.opt.clipboard = "unnamedplus"

-- Performance
-------------
vim.opt.updatetime = 50
