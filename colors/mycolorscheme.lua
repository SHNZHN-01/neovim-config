vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "mycolorscheme"
-- (t_Co is omitted: Neovim always reports 256+ colors, so it is unnecessary.)

-- ============================================================================
-- GUI Colors
--
-- Used when Neovim runs with a GUI / true-color terminal (termguicolors).

local white = "#c8bcac" -- Foreground (slightly dimmed warm off-white)
local black = "#000000" -- Background hard
local yellow = "#c9ad75" -- Yellow (slightly dimmed)
local blue = "#7fbbb3" -- Blue
local green = "#a7c080" -- Green
local turqoise = "#83c092" -- Aqua
local orange = "#e69875" -- Orange
local pink = "#d699b6" -- Purple
local red = "#e67e80" -- Red
local gray1 = "#343f44" -- Background soft
local gray2 = "#3d484d" -- Grey0
local gray3 = "#475258" -- Grey1
local gray4 = "#576268" -- Grey2
local gray5 = "#7a8478" -- Grey light
local gray6 = "#4a555b" -- Grey dim

-- ============================================================================
-- Terminal Colors
--
-- Used when Neovim runs in a 256-color terminal without true color.

local t_white = 223 -- Foreground
local t_black = 0 -- Background hard
local t_yellow = 214 -- Yellow
local t_blue = 109 -- Blue
local t_green = 142 -- Green
local t_turqoise = 108 -- Aqua
local t_orange = 208 -- Orange
local t_pink = 175 -- Purple
local t_gold = 179 -- Gold (close to yellow)
local t_red = 167 -- Red
local t_gray1 = 237 -- Background soft
local t_gray2 = 238 -- Grey0
local t_gray3 = 239 -- Grey1
local t_gray4 = 240 -- Grey2
local t_gray5 = 243 -- Grey light
local t_gray6 = 245 -- Grey dim

-- ============================================================================
-- Helper Functions

-- Mirror of the Vimscript s:Color(): set a highlight with separate GUI and
-- terminal fg/bg. "NONE" leaves an attribute unset. Optional style string
-- ("bold", "italic,underline", ...) is applied to both gui and cterm.
local function hl(group, fg, bg, ctermfg, ctermbg, style)
	local o = {}
	if fg ~= "NONE" then
		o.fg = fg
	end
	if bg ~= "NONE" then
		o.bg = bg
	end
	if ctermfg ~= "NONE" then
		o.ctermfg = ctermfg
	end
	if ctermbg ~= "NONE" then
		o.ctermbg = ctermbg
	end
	if style and style ~= "NONE" then
		o.cterm = {}
		for _, s in ipairs(vim.split(style, ",", { plain = true })) do
			o[s] = true
			o.cterm[s] = true
		end
	end
	vim.api.nvim_set_hl(0, group, o)
end

local function link(from, to)
	vim.api.nvim_set_hl(0, from, { link = to })
end

-- ============================================================================
-- General Syntax Elements

hl("FloatBorder", white, "NONE", t_white, "NONE")
hl("Pmenu", white, black, t_white, t_black)
hl("PmenuSel", white, gray2, t_white, t_gray2)
hl("Cursor", "NONE", gray2, "NONE", t_gray2)
hl("CursorLine", "NONE", gray2, "NONE", t_gray2)
hl("Normal", white, black, t_white, t_black)
hl("NormalFloat", white, black, t_white, t_black)
hl("Search", yellow, "NONE", t_black, t_gray2, "bold")
hl("Title", white, "NONE", t_white, "NONE", "bold")
hl("EndOfBuffer", black, "NONE", t_black, "NONE", "bold")

hl("LineNr", gray4, "NONE", t_gray4, "NONE")
hl("StatusLine", gray5, gray3, t_gray5, t_gray3)
hl("StatusLineNC", gray4, gray3, t_gray4, t_gray3)
hl("StatusLineMarker", yellow, gray3, t_yellow, t_gray3, "bold")
hl("VertSplit", gray3, "NONE", t_gray3, "NONE")
hl("ColorColumn", "NONE", gray6, "NONE", t_gray6)

hl("Folded", gray4, "NONE", t_gray4, "NONE")
hl("FoldColumn", gray3, black, t_gray3, t_black)
hl("ErrorMsg", red, "NONE", t_red, "NONE", "bold")
hl("WarningMsg", yellow, "NONE", t_yellow, "NONE", "bold")
hl("Question", white, "NONE", t_white, "NONE")

hl("SpecialKey", white, gray2, t_white, t_gray2)
hl("Directory", blue, "NONE", t_blue, "NONE")

hl("Comment", gray4, "NONE", t_gray4, "NONE")
hl("Todo", gray5, "NONE", t_gray5, "NONE")
hl("String", green, "NONE", t_green, "NONE")
hl("Keyword", red, "NONE", t_red, "NONE")
hl("Number", turqoise, "NONE", t_turqoise, "NONE")
hl("Regexp", orange, "NONE", t_orange, "NONE")
hl("Macro", orange, "NONE", t_orange, "NONE")
hl("Function", yellow, "NONE", t_yellow, "NONE")
hl("Notice", yellow, "NONE", t_yellow, "NONE")

hl("MatchParen", "NONE", "NONE", "NONE", "NONE", "bold")
hl("Conceal", "NONE", "NONE", "NONE", "NONE", "NONE")

local links = {
	{ "Identifier", "Normal" },
	{ "Constant", "Normal" },
	{ "Operator", "Normal" },
	{ "Type", "Keyword" },
	{ "Statement", "Keyword" },
	{ "PmenuThumb", "PmenuSel" },
	{ "Visual", "Cursor" },
	{ "SignColumn", "FoldColumn" },
	{ "Error", "ErrorMsg" },
	{ "NonText", "LineNr" },
	{ "PreProc", "Normal" },
	{ "Special", "Normal" },
	{ "Boolean", "Keyword" },
	{ "StorageClass", "Keyword" },
	{ "MoreMsg", "Normal" },
	{ "Character", "String" },
	{ "Label", "Special" },
	{ "PreCondit", "Macro" },

	-- CSS
	{ "cssIdentifier", "Title" },
	{ "cssClassName", "Directory" },
	{ "cssMedia", "Notice" },
	{ "cssColor", "Number" },
	{ "cssTagName", "Normal" },
	{ "cssImportant", "Notice" },

	-- D
	{ "dDebug", "Notice" },
	{ "dOperator", "Operator" },
	{ "dStorageClass", "Keyword" },
	{ "dAnnotation", "Directory" },
	{ "dAttribute", "dAnnotation" },

	-- Diffs
	{ "diffFile", "WarningMsg" },
	{ "diffLine", "Number" },
	{ "diffAdded", "String" },
	{ "diffRemoved", "Keyword" },
	{ "DiffChange", "Notice" },
	{ "DiffAdd", "diffAdded" },
	{ "DiffDelete", "diffRemoved" },
	{ "DiffText", "diffLine" },

	-- Git commits
	{ "gitCommitSummary", "String" },
	{ "gitCommitOverflow", "ErrorMsg" },

	-- HTML
	{ "htmlLink", "Directory" },
	{ "htmlSpecialTagName", "htmlTag" },
	{ "htmlTagName", "htmlTag" },
	{ "htmlScriptTag", "htmlTag" },

	-- Javascript
	{ "javaScriptBraces", "Normal" },
	{ "javaScriptMember", "Normal" },
	{ "javaScriptIdentifier", "Keyword" },
	{ "javaScriptFunction", "Keyword" },
	{ "JavaScriptNumber", "Number" },

	-- Java
	{ "javaCommentTitle", "javaComment" },
	{ "javaDocTags", "Todo" },
	{ "javaDocParam", "Todo" },
	{ "javaStorageClass", "Keyword" },
	{ "javaAnnotation", "Directory" },
	{ "javaExternal", "Keyword" },

	-- JSON
	{ "jsonKeyword", "String" },

	-- Less
	{ "lessClass", "cssClassName" },

	-- Make
	{ "makeTarget", "Function" },

	-- Markdown
	{ "markdownListMarker", "Keyword" },
	{ "markdownOrderedListMarker", "Keyword" },

	-- Perl
	{ "podCommand", "Comment" },
	{ "podCmdText", "Todo" },
	{ "podVerbatimLine", "Todo" },
	{ "perlStatementInclude", "Statement" },
	{ "perlStatementPackage", "Statement" },
	{ "perlPackageDecl", "Normal" },

	-- Ruby
	{ "rubySymbol", "Regexp" },
	{ "rubyConstant", "Constant" },
	{ "rubyInstanceVariable", "Directory" },
	{ "rubyClassVariable", "rubyInstanceVariable" },
	{ "rubyClass", "Keyword" },
	{ "rubyModule", "rubyClass" },
	{ "rubyFunction", "Function" },
	{ "rubyDefine", "Keyword" },
	{ "rubyRegexp", "Regexp" },
	{ "rubyRegexpSpecial", "Regexp" },
	{ "rubyRegexpCharClass", "Normal" },
	{ "rubyRegexpQuantifier", "Normal" },
	{ "rubyAttribute", "Identifier" },
	{ "rubyMacro", "Identifier" },

	-- Rust
	{ "rustFuncCall", "Identifier" },
	{ "rustCommentBlockDoc", "Comment" },
	{ "rustCommentLineDoc", "Comment" },

	-- Shell
	{ "shFunctionKey", "Keyword" },
	{ "shTestOpr", "Operator" },
	{ "bashStatement", "Normal" },

	-- SQL
	{ "sqlKeyword", "Keyword" },

	-- TypeScript
	{ "typescriptBraces", "Normal" },
	{ "typescriptEndColons", "Normal" },
	{ "typescriptFunction", "Function" },
	{ "typescriptFuncKeyword", "Keyword" },
	{ "typescriptLogicSymbols", "Operator" },
	{ "typescriptIdentifier", "Keyword" },
	{ "typescriptExceptions", "Keyword" },

	-- YAML
	{ "yamlPlainScalar", "String" },

	-- XML
	{ "xmlTagName", "Normal" },
	{ "xmlTag", "Normal" },
	{ "xmlAttrib", "Normal" },

	-- Vimwiki
	{ "VimWikiCode", "markdownCode" },
}

for _, l in ipairs(links) do
	link(l[1], l[2])
end

-- `hi! NonText guifg=bg`: there is no literal `bg` keyword in nvim_set_hl,
-- so resolve it to the Normal background. This also overrides the
-- NonText -> LineNr link set above (matching the original file's behaviour).
vim.api.nvim_set_hl(0, "NonText", { fg = black })

-- ============================================================================
-- Specific Languages (highlight definitions, not links)

-- Markdown
hl("markdownCodeBlock", green, gray1, t_green, t_gray1)
hl("markdownCode", green, gray1, t_green, t_gray1)

hl("TabLineSel", white, gray2, t_white, t_gray2, "bold")

-- Line numbers
hl("CursorLineNR", yellow, "NONE", t_yellow, "NONE", "bold")

-- Spell checking
hl("SpellBad", red, "NONE", t_red, "NONE", "NONE")

-- ============================================================================
-- Plugin-specific Highlights

-- Indent Blankline
hl("IblIndent", gray1, "NONE", t_gray1, "NONE")
hl("IblWhitespace", gray1, "NONE", t_gray1, "NONE")
hl("IblScope", gray1, "NONE", t_gray1, "NONE")

-- NvimTree
hl("NvimTreeEndOfBuffer", black, black, t_black, t_black)

-- Telescope
hl("TelescopeBorder", white, "NONE", t_white, "NONE")
hl("TelescopeNormal", white, black, t_white, t_black)
hl("TelescopePreviewBorder", white, "NONE", t_white, "NONE")
hl("TelescopePreviewTitle", white, black, t_white, t_black)
hl("TelescopeResultsBorder", white, "NONE", t_white, "NONE")
hl("TelescopeResultsTitle", white, "NONE", t_white, "NONE")
hl("TelescopePromptNormal", "NONE", black, "NONE", t_black)
hl("TelescopePromptBorder", white, "NONE", t_white, "NONE")
hl("TelescopePromptTitle", white, black, t_white, t_black)
hl("TelescopePromptCounter", white, "NONE", t_white, "NONE")
hl("TelescopePromptPrefix", white, "NONE", t_white, "NONE")
hl("TelescopeSelection", "NONE", black, "NONE", t_black)

-- WhichKey
hl("WhichKeyBorder", white, "NONE", t_white, "NONE")

-- Lazy
hl("LazyButton", "NONE", black, "NONE", t_black)
hl("LazyButtonActive", "NONE", black, "NONE", t_black)

-- Dap
hl("DapBreakpointColor", red, "NONE", t_red, "NONE")
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointColor", numhl = "" })
vim.fn.sign_define("DapStopped", { texthl = "DapBreakpointColor" })
hl("DapUIFloatBorder", white, "NONE", t_white, "NONE")
hl("DapUIScope", yellow, "NONE", t_yellow, "NONE")
hl("DapUIThread", yellow, "NONE", t_yellow, "NONE")
hl("DapUIStoppedThread", yellow, "NONE", t_yellow, "NONE")
hl("DapUIType", green, "NONE", t_green, "NONE")
hl("DapUICurrentFrameName", green, "NONE", t_green, "NONE")
hl("DapUIDecoration", white, "NONE", t_white, "NONE")
hl("DapUISource", pink, "NONE", t_pink, "NONE")
hl("DapUILineNumber", gray5, "NONE", t_gray5, "NONE")
hl("DapUIWatchesEmpty", red, "NONE", t_red, "NONE")

-- Dropbar
hl("WinBar", white, black, t_white, t_black)
hl("WinBarNC", white, black, t_white, t_black)
