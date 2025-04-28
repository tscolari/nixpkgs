{
  description = "My Custom package collection";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Helper function to generate per-system attributes
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Package definitions
      mkPackages = pkgs: {
        diagridcli = pkgs.callPackage ./pkgs/diagridcli { };
        vanta-agent = pkgs.callPackage ./pkgs/vanta { };
      };

      # Overlay definition
      overlay = final: prev: mkPackages final;

    in {

      nixosModules = {
        vanta = import ./pkgs/vanta/service.nix;

        default = { pkgs, ... }: {
          imports = [
            self.nixosModules.vanta
          ];
          nixpkgs.overlays = [ overlay ];
        };
      };

      # Expose the overlay
      overlays.default = overlay;

      # Expose the packages directly
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in mkPackages pkgs
      );

      # For `nix run` command
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.diagridcli}/bin/diagrid";
        };
      });
    };
}
