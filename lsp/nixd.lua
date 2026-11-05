-- nixd: nixpkgs (for pkgs.* completion) and NixOS options from the flake of
-- the file's project, so nothing outside this config is needed:
--   nixpkgs   the flake's nixpkgs input; without one (or without a flake),
--             the registry's nixpkgs
--   options   the flake's nixosConfigurations.<this host> (the hostname is
--             the configuration's name on these machines); without one,
--             plain NixOS options from that nixpkgs
local host = vim.uv.os_gethostname()

-- a Nix string literal
local function str(s)
	return '"' .. s:gsub('[\\"$]', "\\%0") .. '"'
end

local function settings(root)
	local registry = '(builtins.getFlake "nixpkgs")'
	local flake = root and vim.uv.fs_stat(root .. "/flake.nix") and ("(builtins.getFlake " .. str(root) .. ")")

	local nixpkgs = registry
	if flake then
		nixpkgs = ("(%s.inputs.nixpkgs or %s)"):format(flake, registry)
	end

	local options = ('(import "${%s}/nixos/lib/eval-config.nix" { modules = [ ]; system = builtins.currentSystem; }).options'):format(
		nixpkgs
	)
	if flake then
		local h = str(host)
		options = ("let c = %s.nixosConfigurations or { }; in if c ? %s then c.%s.options else %s"):format(
			flake,
			h,
			h,
			options
		)
	end

	return {
		nixd = {
			nixpkgs = { expr = ("import (%s) { }"):format(nixpkgs) },
			options = { nixos = { expr = options } },
		},
	}
end

return {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	before_init = function(_, config)
		config.settings = settings(config.root_dir)
	end,
}
