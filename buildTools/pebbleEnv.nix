{ nixpkgs, pebble, system }:

{ devServerIP ? null

, emulatorTarget ? null

, cloudPebble ? false

, nativeBuildInputs ? [ ] }@attrs:

let
  pkgs = import nixpkgs {
    inherit system;
    crossSystem = nixpkgs.lib.systems.examples.arm-embedded;
  };

  rest = builtins.removeAttrs attrs [
    "devServerIP"
    "emulatorTarget"
    "cloudPebble"
    "nativeBuildInputs"
  ];
in pkgs.callPackage ({ gcc9Stdenv, nodejs }:
  gcc9Stdenv.mkDerivation {
    name = "pebble-env";
    phases = [ "nophase" ];

    nativeBuildInputs = with pebble;
      [ nodejs pebble-qemu pebble-tool ] ++ nativeBuildInputs;

    PEBBLE_PHONE = devServerIP;
    PEBBLE_EMULATOR = emulatorTarget;
    PEBBLE_CLOUDPEBBLE = if cloudPebble then "1" else null;

    nophase = ''
      echo This derivation is a Pebble development shell, and not meant to be built.
      exit 1
    '';
  } // rest) { }
