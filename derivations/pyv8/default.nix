{ stdenv, lib, python2, fetchFromGitHub, fetchgit
, ensureNewerSourcesForZipFilesHook, update-python-libraries, darwin, boost153
, linuxPackages, llvmPackages, system, which }:

let
  v8-source = fetchFromGitHub {
    owner = "v8";
    repo = "v8";
    rev = "5acdc942f67c5ac1a8c47252e605b90f689d8fbb";
    sha256 = "0zcypzv7740k165h9pfx36f748xd2xd60l2jmkwgl8n44y8h1d63";
  };

  gyp-source = fetchgit {
    url = "https://chromium.googlesource.com/external/gyp";
    rev = "a3e2a5caf24a1e0a45401e09ad131210bf16b852";
    sha256 = "197y7h2c14qf4na2yf0bclpnhgpxzkkd5lqdy93ahkysh8dr67ya";
  };

  linuxDeps = lib.optionals stdenv.isLinux [ linuxPackages.systemtap ];

  darwinDeps = lib.optionals stdenv.isDarwin (with darwin; [ cctools dtrace ]);

  boost = boost153.override {
    inherit stdenv;
    python = python2;
  };

in with python2.pkgs;
toPythonModule (stdenv.mkDerivation rec {
  name = "python2.7-PyV8";
  version = "1.0.dev";
  src = fetchFromGitHub {
    owner = "pebble";
    repo = "pyv8";
    rev = "0e272accb345a82b19cfd6bd34436a790fa03cc9";
    sha256 = "02jvxydpfkwprrvq0dzj6waxgbx7xhvvhmn2cdcii0yf7v47n1bn";
  };

  nativeBuildInputs = [
    python
    wrapPython
    ensureNewerSourcesForZipFilesHook
    pythonRemoveTestsDirHook
    setuptools
    pythonCatchConflictsHook
    pythonRemoveBinBytecodeHook
    setuptoolsBuildHook
    pipInstallHook
    pythonImportsCheckHook
    which
  ] ++ linuxDeps ++ darwinDeps;

  propagatedBuildInputs = [ python2 boost ];

  strictDeps = true;

  LANG = "${if stdenv.isDarwin then "en_US" else "C"}.UTF-8";

  CXXFLAGS = lib.optionalString stdenv.isDarwin
    "-std=c++11 -stdlib=libc++ -mmacosx-version-min=10.8";
  LDFLAGS =
    lib.optionalString stdenv.isDarwin "-lc++ -mmacosx-version-min=10.8";

  doCheck = false;

  postUnpack = ''
    cp -r ${v8-source} source/v8-source
    chmod -R +w source/v8-source
    export V8_HOME=`pwd`/source/v8-source

    cp -r ${gyp-source} $V8_HOME/build/gyp
    chmod -R +w $V8_HOME/build/gyp
  '';

  patches = [
    ./fix-CreateHandle-scope.patch
    ./fix-extension-build.patch
    ./fix-gyp-darwin.patch
    ./fix-v8-segfault.patch
  ];

  postPatch = ''
    substituteInPlace $V8_HOME/build/gyp/gyp --replace "bash" "sh"
  '' + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace $V8_HOME/Makefile --replace "g++" "clang++"
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  disallowedReferences =
    lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform)
    [ python2.pythonForBuild ];

  dontUsePythonRecompileBytecode = true;

  meta = {
    platforms = python2.meta.platforms;
    isBuildPythonPackage = python2.meta.platforms;
  };
})
