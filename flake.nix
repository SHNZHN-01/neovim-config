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
    let
      # nixpkgs' opencode 2.2.5 has a stale hash for its node_modules (what
      # bun downloads hashes differently), and opencode.nvim depends on
      # opencode: the hash it really has. Only while nixpkgs still has the
      # stale one: once it's fixed or opencode is bumped, this does nothing
      # and can go. In this flake's own packages and in its overlay.
      opencodeFix = _: prev: {
        opencode =
          if
            prev.opencode.node_modules.outputHash or null == "sha256-xfOVcw1+waLVNhFDwzOtzxrUSQEogvn88YomydOlhwc="
          then
            prev.opencode.overrideAttrs (old: {
              node_modules = old.node_modules.overrideAttrs {
                outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
              };
            })
          else
            prev.opencode;
      };
    in
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
            overlays = [ opencodeFix ];
          };

          packages = {
            neovim-shnzhn = pkgs.callPackage ./neovim.nix { src = inputs.self; };
            default = inputs.self.packages.${pkgs.system}.neovim-shnzhn;
          };
        };

      flake = {
        overlays.default = inputs.nixpkgs.lib.composeManyExtensions [
          opencodeFix
          (final: _prev: {
            neovim-shnzhn = final.callPackage ./neovim.nix { src = inputs.self; };
          })
        ];

        nixosModules.default = { pkgs, ... }: {
          nixpkgs.overlays = [ inputs.self.overlays.default ];
          environment.systemPackages = [ pkgs.neovim-shnzhn ];
        };
      };
    };
}
