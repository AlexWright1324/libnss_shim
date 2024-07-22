{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  
  outputs = { self, nixpkgs }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in rec {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./package.nix {};
      });

      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let 
          cfg = config.users.libnss_shim;
        in {
          options.users.libnss_shim = {
            enable = mkEnableOption "Enables libnss_shim";

            config = mkOption rec {
              type = types.attr;
              default = {};
              example = default;
              description = "libnss_shim config";
            };
          };

          config = mkIf cfg.enable {
            system.nssModules = with pkgs; [ packages.default ];
            system.nssDatabases = {
              passwd = mkAfter ["shim"];
              shadow = mkAfter ["shim"];
            };
            environment.etc."libnss_shim/config.json" = {
              text = toJson cfg.config;
            };
          };
        };
    };
}
