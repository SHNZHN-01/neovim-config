-- JavaScript and TypeScript debugging with vscode-js-debug (VS Code's own
-- JavaScript debugger), in its DAP server mode: nvim-dap starts js-debug on
-- a free port for each session. TypeScript is debugged through source maps.
-- The program runs with the `node` on PATH (the project's or the system's).
local dap = require("dap")

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug",
		args = { "${port}", "localhost" },
	},
}

local configurations = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Launch current file (Node)",
		program = "${file}",
		cwd = "${workspaceFolder}",
		sourceMaps = true,
		skipFiles = { "<node_internals>/**" },
		resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
		console = "integratedTerminal",
	},
	{
		-- a node started with --inspect
		type = "pwa-node",
		request = "attach",
		name = "Attach to a Node process",
		processId = require("dap.utils").pick_process,
		cwd = "${workspaceFolder}",
		sourceMaps = true,
		skipFiles = { "<node_internals>/**" },
		resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
	},
}

for _, ft in ipairs({ "javascript", "typescript" }) do
	dap.configurations[ft] = configurations
end
