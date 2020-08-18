{ stdenv, lib, autoPatchelfHook, fetchurl, fetchFromGitHub, makeWrapper
, freetype, python2Packages, pyv8, zlib }:

let
  pythonLibs = import ./python-libs.nix {
    inherit fetchFromGitHub fetchurl lib makeWrapper python2Packages pyv8 stdenv;
  };

  rpath = lib.makeLibraryPath [ freetype stdenv.cc.cc.lib zlib ];
in python2Packages.buildPythonPackage rec {
  pname = "pebble-tool";
  version = "4.6rc1";

  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "pebble-tool";
    rev = "f1b4d08f5b0d99ac50407691065766ce17d2cdb8";
    sha256 = "1hxmk6lhrgrhcikp4zy44mj80fxbqd53wykya97r4ikgbvzyanm6";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = builtins.attrValues pythonLibs
    ++ (with python2Packages; [
      colorama
      enum34
      httplib2
      oauth2client
      packaging
      pyasn1
      pyasn1-modules
      pyqrcode
      pyserial
      requests
      rsa
      virtualenv
      websocket_client

      freetype
    ]);

  postPatch = ''
    substituteInPlace setup.py --replace "==" ">="
    cat requirements.txt
  '';
  patches = [ ./exec-phonesim.patch ./fix-virtualenv-commands.patch ];

  postFixup = ''
    wrapProgram $out/bin/pebble \
      --prefix LD_LIBRARY_PATH : ${rpath} \
      --set PHONESIM_PATH ${pythonLibs.pypkjs}/bin/pypkjs
  '';

  meta = with lib; {
    homepage = "https://developer.rebble.io/developer.pebble.com/index.html";
    description = "Tool for interacting with the Pebble SDK";

    license = licenses.mit;
  };
}
