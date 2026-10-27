-- nixd: hostname == nixosConfigurations attr, so use it directly.
local host = vim.uv.os_gethostname()
local flake = vim.env.FLAKE

return {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = ("import (builtins.getFlake %q).inputs.nixpkgs { }"):format(flake),
			},
			options = {
				nixos = {
					expr = ("(builtins.getFlake %q).nixosConfigurations.%s.options"):format(flake, host),
				},
			},
		},
	},
}
