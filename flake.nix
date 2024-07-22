{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          name = "libnss_shim";

          src = pkgs.fetchFromGitHub {
            owner = "xenago";
            repo = name;
            rev = "f9f8bb7";
            sha256 = "sha256-kTZoBpQH7KbmkKrpgt9Ou9/d35rIi3PA0LOgB2kg1FA=";
          };

          cargoHash = "sha256-aZRu9MpU8oYeFMMzDWAvor8yAYZkXDe81GMt29ewcqs=";
        };
      }
    ) // {
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
