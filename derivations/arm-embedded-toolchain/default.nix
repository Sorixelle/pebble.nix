{
  gccStdenv,
  lib,
  fetchurl,

  autoconf,
  automake,
  bison,
  flex,
  libtool,
  libiconv,
  m4,
  ncurses,
  perl,
  texinfo,
}:

gccStdenv.mkDerivation rec {
  pname = "arm-embedded-toolchain";
  version = "4.7";

  src = fetchurl {
    url = "https://launchpad.net/gcc-arm-embedded/4.7/4.7-2014-q2-update/+download/gcc-arm-none-eabi-4_7-2014q2-20140408-src.tar.bz2";
    hash = "sha256-CwHzgUfawaCKNmE/FQj1U5CVAeW1skPO417sGlG7EJ0=";
  };
  sourceRoot = "gcc-arm-none-eabi-4_7-2014q2-20140408";

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    m4
    perl
    texinfo
  ];

  buildInputs =
    [
      ncurses
    ]
    ++ lib.optionals gccStdenv.isDarwin [
      libiconv
    ];

  postUnpack = ''
    # Extract all tarballs in the source directory
    pushd ${sourceRoot}/src
    find -name "*.tar.*" | xargs -I% tar xf %
    popd
  '';

  patches = [
    ./fix-ppl-build.patch
    ./fix-toolchain-build.patch
  ];

  postPatch = ''
    # Fixup shebangs - /usr/bin/env doesn't exist during build
    patchShebangs build-prerequisites.sh
    patchShebangs build-toolchain.sh

    # Apply zlib patch included in sources
    pushd src/zlib-1.2.5
    patch -p1 < ../zlib-1.2.5.patch
    popd
  '';

  configurePhase = ''
    # Regenrate PPL configure script to apply changes in patch
    pushd src/ppl-0.11
    autoreconf -i
    popd
  '';

  buildPhase = ''
    ./build-prerequisites.sh --skip_mingw32
    ./build-toolchain.sh --skip_mingw32
  '';

  installPhase = ''
    mkdir -p $out
    cp -a install-native/* $out/
  '';

  meta = with lib; {
    homepage = "https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain";
    description = "GNU compiler toolchain for Arm based CPUs";
    license = with licenses; [
      bsd2
      bsd3
      gpl2Plus
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
      lgpl3Plus
      mit
      zlib
    ];
    mainProgram = "arm-none-eabi-gcc";
    platforms = platforms.linux;
    badPlatforms = platforms.darwin;
  };
}
