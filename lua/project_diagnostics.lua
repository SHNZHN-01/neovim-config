-- Project-wide diagnostics from CLI checkers, shown in a Telescope picker.
-- Nothing here touches vim.diagnostic: the results are a one-off snapshot
-- that lives only in the picker (and in quickfix, if you <C-q> it).

local M = {}

-- One job/thread per logical core for checkers whose workers share no startup cost.
local JOBS = tostring(vim.uv.available_parallelism())

local SEV = { error = 1, warning = 2, information = 3, info = 3, note = 4, hint = 4 }
local LETTER = { E = 1, W = 2, I = 3, N = 4, H = 4 }

-- The entry shape telescope's gen_from_diagnostics expects (1-based positions).
local function item(file, lnum, col, sev, text)
	return {
		filename = file,
		lnum = tonumber(lnum) or 1,
		col = tonumber(col) or 1,
		type = vim.diagnostic.severity[sev] or "WARN",
		text = (tostring(text or "")):gsub("\n", " "),
	}
end

local function abs(root, file)
	if not vim.startswith(file, "/") then
		file = root .. "/" .. file
	end
	return vim.fs.normalize(file)
end

local function project_root(markers)
	local marker = vim.fs.find(markers, { upward = true, path = vim.fn.getcwd() })[1]
	return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

-- Run a command asynchronously; parse its result on the main loop.
local function run(cmd, opts, parse, cb)
	if vim.fn.executable(cmd[1]) == 0 then
		vim.notify(cmd[1] .. " not found on PATH", vim.log.levels.WARN)
		return cb({})
	end
	local t0 = vim.uv.hrtime()
	vim.system(cmd, { text = true, cwd = opts.cwd }, function(res)
		vim.schedule(function()
			vim.notify(("%s: %.1fs"):format(cmd[1], (vim.uv.hrtime() - t0) / 1e9))
			local ok, items = pcall(parse, res)
			if not ok then
				vim.notify(("%s: failed to parse output: %s"):format(cmd[1], items), vim.log.levels.ERROR)
				items = {}
			end
			cb(items)
		end)
	end)
end

-- Run several runners in parallel, call cb once with everything merged.
local function gather(runners, root, cb)
	local all, pending = {}, #runners
	if pending == 0 then
		return cb(all)
	end
	for _, r in ipairs(runners) do
		r(root, function(items)
			vim.list_extend(all, items)
			pending = pending - 1
			if pending == 0 then
				cb(all)
			end
		end)
	end
end

---------------------------------------------------------------------------
-- Runners: each is fn(root, cb) and calls cb(items)
---------------------------------------------------------------------------

-- Project config files emmylua_check looks for in the workspace by itself.
local EMMYLUA_CONFIGS = { ".emmyrc.json", ".emmyrc.lua", ".luarc.json" }

local function emmylua(root, cb)
	local tmp = vim.fn.tempname()
	vim.fn.mkdir(tmp, "p")
	local out = tmp .. "/check.json"
	local cmd = { "emmylua_check", "--output-format", "json", "--output", out }
	-- Without a project config, reuse the settings from lsp/emmylua_ls.lua so the
	-- CLI sees the same library (Neovim runtime + plugins) as the editor does.
	local has_config = vim.iter(EMMYLUA_CONFIGS):any(function(name)
		return vim.uv.fs_stat(root .. "/" .. name) ~= nil
	end)
	if not has_config then
		local cfg = vim.lsp.config.emmylua_ls
		local settings = cfg and cfg.settings and cfg.settings.emmylua
		if settings then
			local emmyrc = tmp .. "/.emmyrc.json"
			vim.fn.writefile({ vim.json.encode(settings) }, emmyrc)
			vim.list_extend(cmd, { "--config", emmyrc })
		end
	end
	table.insert(cmd, root)
	run(cmd, { cwd = root }, function()
		local f = io.open(out)
		if not f then
			return {}
		end
		local data = vim.json.decode(f:read("*a"))
		f:close()
		-- [{ file = "/abs/path.lua", diagnostics = { <LSP Diagnostic>... } }, ...]
		local items = {}
		for _, entry in ipairs(data) do
			for _, d in ipairs(entry.diagnostics or {}) do
				local s = d.range.start
				local code = (type(d.code) == "string" or type(d.code) == "number") and d.code or nil
				local text = code and ("%s (%s)"):format(d.message, code) or d.message
				items[#items + 1] = item(entry.file, s.line + 1, s.character + 1, d.severity, text)
			end
		end
		return items
	end, cb)
end

-- ty's GitLab Code Quality output is its only JSON format.
local TY_SEVERITY = { info = 3, minor = 2, major = 1, critical = 1, blocker = 1 }

local function ty(root, cb)
	run({ "ty", "check", "--output-format", "gitlab", "--exit-zero" }, { cwd = root }, function(res)
		local stdout = res.stdout or ""
		if not stdout:match("^%s*%[") then
			return {} -- nothing to report (ty prints a plain message instead of JSON)
		end
		local items = {}
		for _, d in ipairs(vim.json.decode(stdout)) do
			local loc = d.location or {}
			local begin = loc.positions and loc.positions.begin or {}
			if loc.path then
				-- description is already "<rule>: <message>"
				items[#items + 1] =
					item(abs(root, loc.path), begin.line, begin.column, TY_SEVERITY[d.severity], d.description)
			end
		end
		return items
	end, cb)
end

local function ruff(root, cb)
	run({ "ruff", "check", "--output-format=json", "--exit-zero", "." }, { cwd = root }, function(res)
		local items = {}
		for _, d in ipairs(vim.json.decode(res.stdout)) do
			local has_code = type(d.code) == "string"
			local text = has_code and ("%s (%s)"):format(d.message, d.code) or d.message
			-- ruff reports syntax errors with no rule code
			items[#items + 1] =
				item(abs(root, d.filename), d.location.row, d.location.column, has_code and 2 or 1, text)
		end
		return items
	end, cb)
end

-- Output parsers for the Nix linters, shared with live_lint.lua (which runs the
-- same tools on a single buffer). `root` resolves relative paths in the output.
M.parse = {}

function M.parse.statix(stdout, root)
	local items = {}
	for line in vim.gsplit(stdout or "", "\n") do
		local file, lnum, col, typ, code, msg = line:match("^(.+)>(%d+):(%d+):(%a):(%d+):(.*)$")
		if file then
			items[#items + 1] = item(abs(root, file), lnum, col, LETTER[typ], ("%s (W%s)"):format(vim.trim(msg), code))
		end
	end
	return items
end

function M.parse.deadnix(stdout, root)
	local items = {}
	for line in vim.gsplit(stdout or "", "\n") do
		if line ~= "" then
			local report = vim.json.decode(line)
			for _, r in ipairs(report.results or {}) do
				items[#items + 1] = item(abs(root, report.file), r.line, r.column, 2, r.message)
			end
		end
	end
	return items
end

local function statix(root, cb)
	run({ "statix", "check", "-o", "errfmt", root }, { cwd = root }, function(res)
		return M.parse.statix(res.stdout, root)
	end, cb)
end

local function deadnix(root, cb)
	run({ "deadnix", "-o", "json", root }, { cwd = root }, function(res)
		return M.parse.deadnix(res.stdout, root)
	end, cb)
end

local function find_compile_commands(root)
	return vim.fs.find("compile_commands.json", { upward = true, path = vim.fn.getcwd(), stop = vim.fs.dirname(root) })[1]
		or vim.fs.find("compile_commands.json", { path = root, limit = 1 })[1]
end

local function clang_tidy(root, cb)
	local cc = find_compile_commands(root)
	if not cc then
		vim.notify("compile_commands.json not found", vim.log.levels.WARN)
		return cb({})
	end
	local build_dir = vim.fs.dirname(cc)
	local db = vim.json.decode(table.concat(vim.fn.readfile(cc), "\n"))
	local seen, files = {}, {}
	for _, entry in ipairs(db) do
		local file = entry.file and abs(entry.directory or build_dir, entry.file)
		if file and not seen[file] then
			seen[file] = true
			files[#files + 1] = file
		end
	end
	if #files == 0 then
		return cb({})
	end
	local cmd
	if vim.fn.executable("run-clang-tidy") == 1 then
		-- One clang-tidy process per translation unit, JOBS at a time. With no file
		-- arguments it checks every entry in compile_commands.json, i.e. `files`.
		cmd = { "run-clang-tidy", "-p", build_dir, "-quiet", "-j", JOBS }
	else
		cmd = { "clang-tidy", "-p", build_dir, "--quiet" }
		vim.list_extend(cmd, files)
	end
	run(cmd, { cwd = build_dir }, function(res)
		local items = {}
		for line in vim.gsplit(res.stdout or "", "\n") do
			local file, lnum, col, sev, msg = line:match("^(.-):(%d+):(%d+): (%a+): (.*)$")
			if file and SEV[sev] then
				items[#items + 1] = item(abs(build_dir, file), lnum, col, SEV[sev], msg)
			end
		end
		return items
	end, cb)
end

---------------------------------------------------------------------------
-- Languages: when each applies, and which runners it uses
---------------------------------------------------------------------------

-- Tracked + untracked-but-not-ignored files, straight from git's index: much
-- faster than walking the tree, and never descends into build/ or result/.
local function project_files(root)
	local res = vim.system(
		{ "git", "ls-files", "--cached", "--others", "--exclude-standard" },
		{ cwd = root, text = true }
	)
		:wait()
	return res.code == 0 and vim.split(res.stdout, "\n", { trimempty = true }) or nil
end

local function has_ext(ext)
	local suffix = "." .. ext
	return function(root, files)
		if files then
			for _, f in ipairs(files) do
				if f:sub(-#suffix) == suffix then
					return true
				end
			end
			return false
		end
		-- not a git repo: fall back to walking the tree
		return #vim.fs.find(function(name)
			return name:sub(-#suffix) == suffix
		end, { path = root, type = "file", limit = 1 }) > 0
	end
end

local languages = {
	{ name = "lua", applies = has_ext("lua"), runners = { emmylua } },
	{ name = "python", applies = has_ext("py"), runners = { ty, ruff } },
	{ name = "nix", applies = has_ext("nix"), runners = { statix, deadnix } },
	{
		name = "clang_tidy",
		applies = function(root)
			return find_compile_commands(root) ~= nil
		end,
		runners = { clang_tidy },
	},
}

---------------------------------------------------------------------------
-- Picker
---------------------------------------------------------------------------

local function show(items, what)
	-- A header included by several translation units gets reported once per TU.
	local seen, unique = {}, {}
	for _, it in ipairs(items) do
		local key = table.concat({ it.filename, it.lnum, it.col, it.type, it.text }, "\0")
		if not seen[key] then
			seen[key] = true
			unique[#unique + 1] = it
		end
	end
	items = unique
	if #items == 0 then
		vim.notify(what .. ": no diagnostics")
		return
	end
	table.sort(items, function(a, b)
		if a.filename ~= b.filename then
			return a.filename < b.filename
		end
		return a.lnum < b.lnum
	end)
	local conf = require("telescope.config").values
	local opts = {}
	require("telescope.pickers")
		.new(opts, {
			finder = require("telescope.finders").new_table({
				results = items,
				entry_maker = require("telescope.make_entry").gen_from_diagnostics(opts),
			}),
			previewer = conf.qflist_previewer(opts),
			-- lets you type e.g. ":error:" to filter by severity, like builtin.diagnostics
			sorter = conf.prefilter_sorter({ tag = "type", sorter = conf.generic_sorter(opts) }),
		})
		:find()
	vim.notify(("%s: %d diagnostics"):format(what, #items))
end

local ROOT_MARKERS = { ".git", "flake.nix" }

--- Every language that applies to the project, merged into one picker.
function M.workspace()
	local root = project_root(ROOT_MARKERS)
	local files = project_files(root)
	local runners, names = {}, {}
	for _, lang in ipairs(languages) do
		if lang.applies(root, files) then
			vim.list_extend(runners, lang.runners)
			names[#names + 1] = lang.name
		end
	end
	if #runners == 0 then
		vim.notify("No supported languages found in " .. root, vim.log.levels.WARN)
		return
	end
	vim.notify(("Checking %s (%s)..."):format(root, table.concat(names, ", ")))
	gather(runners, root, function(items)
		show(items, "Workspace diagnostics")
	end)
end

-- Single-language entry points: M.lua(), M.python(), M.nix(), M.clang_tidy()
for _, lang in ipairs(languages) do
	M[lang.name] = function()
		local root = project_root(ROOT_MARKERS)
		vim.notify(("%s: checking %s..."):format(lang.name, root))
		gather(lang.runners, root, function(items)
			show(items, lang.name)
		end)
	end
end

return M
