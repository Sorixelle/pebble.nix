{ stdenv, lib, fetchFromGitHub, autoconf, automake, glib, libtool, perl, pixman
, pkgconfig, python2, SDL2, zlib }:

stdenv.mkDerivation rec {
  name = "pebble-qemu";
  version = "2.5.0-pebble4";

  src = fetchFromGitHub {
    owner = "pebble";
    repo = "qemu";
    rev = "v${version}";
    sha256 = "1r7692hhd70nrbscznc33vi3ndv51sdlg9vc0ay4h4s1xrqv5d0g";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoconf automake libtool perl pkgconfig python2 ];

  buildInputs = [ glib pixman SDL2 zlib ];

  patches = [ ./memfd-fix.patch ./undefined-reference-major.patch ];

  configureFlags = [
    "--with-coroutine=gthread"
    "--disable-werror"
    "--disable-mouse"
    "--disable-vnc"
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