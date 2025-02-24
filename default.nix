let
  system = builtins.currentSystem;

  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake =
    (import (fetchTarball {
      url =
        flakeLock.nodes.flake-compat.locked.url
          or "https://github.com/edolstra/flake-compat/archive/${flakeLock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = flakeLock.nodes.flake-compat.locked.narHash;
    }) { src = ./.; }).defaultNix.outputs;
in
{
  buildPebbleApp = flake.buildPebbleApp.${system};
  packages = flake.packages.${system};
  pebbleEnv = flake.pebbleEnv.${system};

  packagesAllArchs = flake.packages;
}
