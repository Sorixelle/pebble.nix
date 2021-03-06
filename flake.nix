{
  description = "Tools for building Pebble apps on Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [ "i686-linux" "x86_64-linux" "x86_64-darwin" ]
    (system:
      let pkgs = import nixpkgs { inherit system; };
      in rec {
        pebbleEnv = import ./buildTools/pebbleEnv.nix {
          inherit nixpkgs system;
          pebble = self.packages.${system};
        };

        buildPebbleApp = import ./buildTools/buildPebbleApp.nix {
          inherit nixpkgs system;
          pebble-tool = packages.pebble-tool;
          pypng = (pkgs.callPackage ./derivations/pebble-tool/python-libs.nix {
            pyv8 = packages.pyv8;
          }).pypng;
        };

        packages = rec {
          boost153 = pkgs.callPackage ./derivations/boost153 { };

          pebble-qemu = pkgs.callPackage ./derivations/pebble-qemu { };
          pebble-tool =
            pkgs.callPackage ./derivations/pebble-tool { inherit pyv8; };

          pyv8 = pkgs.callPackage ./derivations/pyv8 {
            stdenv = if system == "x86_64-darwin" then
              pkgs.stdenv
            else
              pkgs.gcc49Stdenv;
            inherit boost153;
          };
        };
      });
}
