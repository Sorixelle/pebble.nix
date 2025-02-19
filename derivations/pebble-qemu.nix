{
  stdenv,
  lib,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  darwin,
  flex,
  glib,
  libtool,
  perl,
  pixman,
  pkg-config,
  python2,
  SDL2,
  zlib,
}:

let
  darwinDeps = lib.optionals stdenv.isDarwin (
    with darwin.apple_sdk.frameworks;
    with darwin.stubs;
    [
      CoreAudio
      IOKit
      rez
      setfile
    ]
  );
in
stdenv.mkDerivation rec {
  name = "pebble-qemu";
  version = "2.5.0-pebble5";

  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "qemu";
    rev = "v${version}";
    hash = "sha256-lZoo+GZwmTbTwa/ZhOU6c91IgLdSbC8wHb38pa62Lfs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    perl
    pkg-config
    python2
  ];

  buildInputs = [
    glib
    pixman
    SDL2
    zlib
  ] ++ darwinDeps;

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
