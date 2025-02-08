{ stdenv, lib, fetchFromGitHub, autoconf, automake, bison, darwin, flex, glib, libtool, perl
, pixman, pkg-config, python2, SDL2, zlib }:

let
  darwinDeps = lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks;
    with darwin.stubs; [
      CoreAudio
      IOKit
      rez
      setfile
    ]);

  linuxPatches =
    lib.optionals (!stdenv.isDarwin) [ ./undefined-reference-major.patch ];
in stdenv.mkDerivation rec {
  name = "pebble-qemu";
  version = "2.5.0-pebble4";

  src = (fetchFromGitHub {
    owner = "pebble";
    repo = "qemu";
    rev = "v${version}";
    sha256 = "1r7692hhd70nrbscznc33vi3ndv51sdlg9vc0ay4h4s1xrqv5d0g";
    fetchSubmodules = true;
  }).overrideAttrs (_: {
    GIT_CONFIG_COUNT = 3;
    # pebble/qemu references a git://github.com URL, which won't work as of 2022.
    GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
    GIT_CONFIG_VALUE_0 = "git://github.com/";
    # Qemu repos moved to GitLab
    GIT_CONFIG_KEY_1 = "url.https://gitlab.com/qemu-project/.insteadOf";
    GIT_CONFIG_VALUE_1 = "git://git.qemu-project.org/";
    # freedesktop.org Anongit no longer works - use GitLab directly
    GIT_CONFIG_KEY_2 = "url.https://gitlab.freedesktop.org/pixman/pixman.insteadOf";
    GIT_CONFIG_VALUE_2 = "git://anongit.freedesktop.org/pixman";
  });

  nativeBuildInputs = [ autoconf automake bison flex libtool perl pkg-config python2 ];

  buildInputs = [ glib pixman SDL2 zlib ] ++ darwinDeps;

  patches = [ ./memfd-fix.patch ./stm32-includes.patch ./version-file-rename.patch ] ++ linuxPatches;

  configureFlags = [
    "--with-coroutine=gthread"
    "--disable-werror"
    "--disable-mouse"
    "--disable-vnc"
    "--disable-cocoa"
    "--enable-debug"
    "--enable-sdl"
    "--with-sdlabi=2.0"
    "--target-list=arm-softmmu"
    "--extra-cflags=-DSTM32_UART_NO_BAUD_DELAY"
    "--extra-ldflags=-g"
  ];

  postInstall = ''
    mv $out/bin/qemu-system-arm $out/bin/qemu-pebble
  '';

  meta = with lib; {
    homepage = "https://github.com/pebble/qemu";
    description = "Fork of QEMU with support for Pebble devices";

    license = licenses.gpl2Plus;
  };
}
