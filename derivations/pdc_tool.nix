{
  stdenv,
  lib,
  fetchzip,
}:

let
  version = "0.3.1";

  binaryArchive = {
    x86_64-linux = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_linux_x86_64-unknown-linux-musl.zip";
      hash = "sha256-J9P+EJKSw6oqptEPQN/xWEXvFd6seX3UQKLMw9Eac4U=";
    };
    x86_64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_x86_64-apple-darwin.zip";
      hash = "sha256-E4PvbYVa8ntcR9aQjtD2whNgYowr1NWOQJu88AiGeyk=";
    };
    aarch64-darwin = fetchzip {
      url = "https://github.com/HBehrens/pdc_tool/releases/download/v${version}/pdc_tool_macos_aarch64-apple-darwin.zip";
      hash = "sha256-2DEZ9MJgfWCtWQLik1HqrdklDRh+YerUgjYnwGSNq68=";
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
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
