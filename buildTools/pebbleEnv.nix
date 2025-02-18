{
  pebbleCrossPkgs,
  pkgs,
  pebble,
  system,
}:

{
  devServerIP ? null,
  emulatorTarget ? null,
  cloudPebble ? false,
  nativeBuildInputs ? [ ],
  CFLAGS ? "",
}@attrs:

let
  isAppleSilicon = system == "aarch64-darwin";
  shellPkgs = if isAppleSilicon then pebbleCrossPkgs else pkgs;

  rest = builtins.removeAttrs attrs [
    "devServerIP"
    "emulatorTarget"
    "cloudPebble"
    "nativeBuildInputs"
    "CFLAGS"
  ];
in
shellPkgs.callPackage (
  {
    gccStdenv,
    lib,
    nodejs,
  }:
  gccStdenv.mkDerivation {
    name = "pebble-env";
    phases = [ "nophase" ];

    nativeBuildInputs =
      [
        nodejs
        pebble.pebble-qemu
        pebble.pebble-tool
      ]
      ++ lib.optionals (!isAppleSilicon) [
        pebble.arm-embedded-toolchain
      ]
      ++ nativeBuildInputs;

    PEBBLE_PHONE = devServerIP;
    PEBBLE_EMULATOR = emulatorTarget;
    PEBBLE_CLOUDPEBBLE = if cloudPebble then "1" else null;

    CFLAGS = (lib.optionalString isAppleSilicon "-Wno-error -include sys/types.h ") + CFLAGS;

    nophase = ''
      echo This derivation is a Pebble development shell, and not meant to be built.
      exit 1
    '';
  }
  // rest
) { }
