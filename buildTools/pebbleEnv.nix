{ nixpkgs, pebble, system }:

{ devServerIP ? null

, emulatorTarget ? null

, cloudPebble ? false

, nativeBuildInputs ? [ ]

, CFLAGS ? "" }@attrs:

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
in pkgs.callPackage ({ gccStdenv, nodejs }:
  gccStdenv.mkDerivation {
    name = "pebble-env";
    phases = [ "nophase" ];

    nativeBuildInputs = with pebble;
      [ nodejs pebble-qemu pebble-tool ] ++ nativeBuildInputs;

    PEBBLE_PHONE = devServerIP;
    PEBBLE_EMULATOR = emulatorTarget;
    PEBBLE_CLOUDPEBBLE = if cloudPebble then "1" else null;

    CFLAGS = "-Wno-error=builtin-macro-redefined -Wno-error=builtin-declaration-mismatch -include sys/types.h " + CFLAGS;

    nophase = ''
      echo This derivation is a Pebble development shell, and not meant to be built.
      exit 1
    '';
  } // rest) { }
