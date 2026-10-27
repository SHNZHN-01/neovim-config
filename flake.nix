{
  description = "Self-contained Neovim with plugins, packaged via flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages = {
            neovim-shnzhn = pkgs.callPackage ./neovim.nix { src = inputs.self; };
            default = inputs.self.packages.${pkgs.system}.neovim-shnzhn;
          };
        };

      flake = {
        overlays.default = final: _prev: {
          neovim-shnzhn = final.callPackage ./neovim.nix { src = inputs.self; };
        };

        nixosModules.default = { pkgs, ... }: {
          nixpkgs.overlays = [ inputs.self.overlays.default ];
          environment.systemPackages = [ pkgs.neovim-shnzhn ];
        };
      };
    };
}
