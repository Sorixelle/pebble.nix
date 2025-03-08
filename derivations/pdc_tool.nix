{
  stdenv,
  lib,
  fetchzip,
}:

let
  version = "0.3.0";

  binaryArchive = {
    x86_64-linux = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_linux_x86_64-unknown-linux-musl.zip";
      hash = "sha256-TGDV2/dwWpOu3xK9Lc5K15EiKrfL0pJKQR1VIlCqpmo=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_x86_64-apple-darwin.zip";
      hash = "sha256-c/d6dYNHL0kDWqBPYvOkkg2XZAlSe8mVRLGM1ng/UkE=";
    };
    aarch64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_aarch64-apple-darwin.zip";
      hash = "sha256-4MJJkb/kvmPlzdBs4KrdpcaMmUkD8Qyb03TgqC7OZ1Y=";
    };
  };
in
stdenv.mkDerivation {
  pname = "pdc_tool";
  inherit version;

  src = binaryArchive.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 pdc_tool $out/bin
  '';

  meta = {
    description = "Command-line interface for working with Pebble Draw Command (PDC) files";
    homepage = "https://github.com/HBehrens/pdc_tool";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = lib.sourceTypes.binaryNativeCode;
  };
}
