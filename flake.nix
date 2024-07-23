{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ( { moduleWithSystem, ... }: rec {
      systems = [
        "x86_64-linux"
      ];

      perSystem = { pkgs, system, ... }: {
        packages.default = pkgs.callPackage ./package.nix {};
      };

      flake = {
        nixosModules.default = moduleWithSystem (
          perSystem @ { config }:
          { config, lib, pkgs, ... }:
          with lib;
          let
            cfg = config.users.libnss_shim;
          in {
            options.users.libnss_shim = {
              enable = mkEnableOption "Enables libnss_shim";

              configJson = mkOption rec {
                type = types.attrs;
                default = {};
                example = default;
                description = "libnss_shim config";
              };
            };

            config = mkIf cfg.enable {
              system.nssModules = with pkgs; [ perSystem.config.packages.default ];
              system.nssDatabases = {
                passwd = mkAfter ["shim"];
                shadow = mkAfter ["shim"];
              };
              environment.etc."libnss_shim/config.json" = {
                text = builtins.toJSON cfg.configJson;
              };
            };
          });

        nixosConfigurations.test =
          inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              flake.nixosModules.default
              ({ pkgs, ... }: {
                boot.isContainer = true;
                users.libnss_shim.enable = true;
              })
            ];
          };
      };
    });
}
