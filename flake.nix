{
  description = "Tools for building Pebble apps on Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [ "i686-linux" "x86_64-linux" "x86_64-darwin" ]
    (system:
      let pkgs = import nixpkgs {
        inherit system;
        config = {
          permittedInsecurePackages = [ "python-2.7.18.8" "python-2.7.18.8-env" ];
        };
      };
      in rec {
        pebbleEnv = import ./buildTools/pebbleEnv.nix {
          inherit nixpkgs system;
          pebble = self.packages.${system};
        };

        buildPebbleApp = import ./buildTools/buildPebbleApp.nix {
          inherit pkgs nixpkgs system;
          pebble-tool = packages.pebble-tool;
          python-libs = pkgs.callPackage ./derivations/pebble-tool/python-libs.nix {
            pyv8 = packages.pyv8;
          };
        };

        packages = rec {
          boost153 = pkgs.callPackage ./derivations/boost153 { };

          pebble-qemu = pkgs.callPackage ./derivations/pebble-qemu { };
          pebble-tool =
            pkgs.callPackage ./derivations/pebble-tool { inherit pyv8; };

          pyv8 = pkgs.callPackage ./derivations/pyv8 {
            inherit boost153;
          };
        };
      });
}
