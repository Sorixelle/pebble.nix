{ nixpkgs, pebble, system }:

{ devServerIP ? null

, emulatorTarget ? null

, nativeBuildInputs ? [ ] }@attrs:

let
  pkgs = import nixpkgs {
    inherit system;
    crossSystem = nixpkgs.lib.systems.examples.arm-embedded;
  };

  rest = builtins.removeAttrs attrs [
    "devServerIP"
    "emulatorTarget"
    "nativeBuildInputs"
  ];
in pkgs.callPackage ({ gcc8Stdenv, nodejs }:
  gcc8Stdenv.mkDerivation {
    name = "pebble-dev-shell";
    phases = [ "nophase" ];

    nativeBuildInputs = with pebble.${system}; [ nodejs pebble-qemu pebble-tool ]
      ++ nativeBuildInputs;

    PEBBLE_PHONE = devServerIP;
    PEBBLE_EMULATOR = emulatorTarget;

    nophase =
      "echo This derivation is a Pebble development shell, and not meant to be built.; exit 1";
  } // rest) { }
