{
  stdenv,
  lib,
  fetchurl,
  icu,
  expat,
  zlib,
  bzip2,
  python,
  fixDarwinDylibNames,
  enableRelease ? true,
  enableDebug ? false,
  enableSingleThreaded ? false,
  enableMultiThreaded ? true,
  enableShared ? true,
  enableStatic ? false,
  enablePIC ? false,
  enableExceptions ? false,
  taggedLayout ? (
    (enableRelease && enableDebug)
    || (enableSingleThreaded && enableMultiThreaded)
    || (enableShared && enableStatic)
  ),
  toolset ? if stdenv.cc.isClang then "clang" else null,
}:

with lib;
let
  variant = concatStringsSep "," (optional enableRelease "release" ++ optional enableDebug "debug");

  threading = concatStringsSep "," (
    optional enableSingleThreaded "single" ++ optional enableMultiThreaded "multi"
  );

  link = concatStringsSep "," (optional enableShared "shared" ++ optional enableStatic "static");

  # To avoid library name collisions
  layout = if taggedLayout then "tagged" else "system";

  silenceClangError = if stdenv.cc.isClang then " -Wno-enum-constexpr-conversion" else "";

  cflags =
    if enablePIC && enableExceptions then
      ''cflags="-fPIC -fexceptions" cxxflags="-fPIC -std=c++11${silenceClangError}" linkflags=-fPIC''
    else if enablePIC then
      ''cflags=-fPIC cxxflags="-fPIC -std=c++11${silenceClangError}" linkflags=-fPIC''
    else if enableExceptions then
      ''cflags=-fexceptions cxxflags="-std=c++11${silenceClangError}"''
    else
      ''cxxflags="-std=c++11${silenceClangError}"'';

  b2Args = concatStringsSep " " (
    [
      "-j$NIX_BUILD_CORES"
      "-sEXPAT_INCLUDE=${expat.dev}/include"
      "-sEXPAT_LIBPATH=${expat.out}/lib"
      "--layout=${layout}"
      "variant=${variant}"
      "threading=${threading}"
      "link=${link}"
      cflags
    ]
    ++ optional (toolset != null) "toolset=${toolset}"
  );
in
stdenv.mkDerivation {
  name = "boost-1.53.0";

  meta = {
    homepage = "http://boost.org/";
    description = "Boost C++ Library Collection";
    license = "boost-license";

    platforms = platforms.unix;
  };

  src = fetchurl {
    url = "mirror://sourceforge/boost/boost_1_53_0.tar.bz2";
    sha256 = "15livg6y1l3gdsg6ybvp3y4gp0w3xh1rdcq5bjf0qaw804dh92pq";
  };

  patches = [
    ./darwin-no-system-python.patch
    ./glib-fixes.patch
  ];

  preConfigure = ''
    if test -f tools/build/src/tools/clang-darwin.jam ; then
        substituteInPlace tools/build/src/tools/clang-darwin.jam \
          --replace '@rpath/$(<[1]:D=)' "$out/lib/\$(<[1]:D=)";
    fi;
  '';

  NIX_CFLAGS_LINK = lib.optionalString stdenv.isDarwin "-headerpad_max_install_names";

  enableParallelBuilding = true;

  buildInputs = [
    icu
    expat
    zlib
    bzip2
    python
  ] ++ optional stdenv.isDarwin fixDarwinDylibNames;

  configureScript = "./bootstrap.sh";
  configureFlags = [
    "--with-icu=${icu.dev}"
    "--with-python=${python.interpreter}"
    "--with-libraries=python,thread"
  ] ++ optional (toolset != null) "--with-toolset=${toolset}";

  buildPhase = "./b2 ${b2Args} install";

  # normal install does not install bjam, this is a separate step
  installPhase = ''
    cd tools/build/v2
    sh bootstrap.sh
    ./b2 ${b2Args} install
  '';
}
