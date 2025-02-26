{
  description = "A new Pebble app";

  inputs = {
    pebble.url = "github:Sorixelle/pebble.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { pebble, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = pebble.pebbleEnv.${system} { };
    });
}
