{
  buildGoModule,
  lib,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "pdc-sequencer";
  version = "1";

  src = fetchFromGitHub {
    owner = "pebble-dev";
    repo = "bobby-assistant";
    rev = "42a9b6fd20622854cb62dd8fecddcd0a8e7a05ae";
    hash = "sha256-BFN9BYpEJc2B1Vh1taO8FWVrpFI5pS0ImcPFAGSH+pQ=";
  };
  sourceRoot = "source/tools/pdc-sequencer";

  vendorHash = null;

  meta = {
    description = "Tool for constructing PDC sequences";
    homepage = "https://github.com/pebble-dev/bobby-assistant/blob/main/tools/pdc-sequencer";
    license = lib.licenses.asl20;
  };
}
