{
  description = "Tools for building Pebble apps on Nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [ "i686-linux" "x86_64-linux" "x68_64-darwin" ]
    (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShell = builtins.trace flake-utils import ./derivations/dev-shell.nix {
          inherit nixpkgs system;
          pebble = self.packages.${system};
        };

        packages.${system} = {
          pebble-qemu = pkgs.callPackage ./derivations/pebble-qemu { };
          pebble-tool = pkgs.callPackage ./derivations/pebble-tool { };
        };
      });
}