{ stdenv, lib, autoPatchelfHook, fetchurl, fetchFromGitHub, makeWrapper
, freetype, python2Packages, pyv8, zlib }:

let
  pythonLibs = import ./python-libs.nix {
    inherit fetchFromGitHub fetchurl lib makeWrapper python2Packages pyv8
      stdenv;
  };

  rpath = lib.makeLibraryPath [ freetype stdenv.cc.cc.lib zlib ];
in python2Packages.buildPythonPackage rec {
  pname = "pebble-tool";
  version = "4.6rc2";

  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "pebble-tool";
    rev = "92561f5c075fe5c812b69409ef338a3548928472";
    sha256 = "1070jkkzg9ba1vp4gq3yfxw456gzajw37kidh1qiv1wawb655j9q";
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
