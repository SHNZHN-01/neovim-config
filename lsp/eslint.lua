-- ESLint, through its language server (vscode-eslint-language-server). It
-- runs the project's own ESLint with the project's own config, so it lints
-- exactly as the project's CI does. Starts only in a project with an ESLint
-- config; its fixes are code actions (gra). Formatting is Prettier's
-- (conform.lua), not ESLint's.
local configs = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
	".eslintrc",
}

return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, configs)
		if root then
			on_dir(root)
		end
	end,
	-- The server asks for all of these and fails without them.
	settings = {
		validate = "on",
		run = "onType",
		format = false,
		quiet = false,
		onIgnoredFiles = "off",
		rulesCustomizations = {},
		problems = { shortenToSingleLine = false },
		nodePath = "",
		-- each file is linted from the directory of its nearest config (monorepos)
		workingDirectory = { mode = "location" },
		codeActionOnSave = { enable = false, mode = "all" },
		codeAction = {
			disableRuleComment = { enable = true, location = "separateLine" },
			showDocumentation = { enable = true },
		},
	},
	before_init = function(_, config)
		config.settings.workspaceFolder = {
			uri = vim.uri_from_fname(config.root_dir),
			name = vim.fn.fnamemodify(config.root_dir, ":t"),
		}
	end,
	handlers = {
		-- "this project's ESLint wants to run": yes (4 = always allow)
		["eslint/confirmESLintExecution"] = function()
			return 4
		end,
		["eslint/noLibrary"] = function()
			vim.notify("ESLint: the project has a config but no eslint installed (npm install?)", vim.log.levels.WARN)
			return {}
		end,
		["eslint/probeFailed"] = function()
			vim.notify("ESLint: probing the project failed", vim.log.levels.WARN)
			return {}
		end,
		["eslint/openDoc"] = function(_, result)
			if result then
				vim.ui.open(result.url)
			end
			return {}
		end,
	},
}
