{ nixpkgs, pebble-tool, pypng, system }:

{ name, src, nativeBuildInputs ? [ ], postUnpack ? "", type, description
, releaseNotes, category ? "", banner ? "", smallIcon ? "", largeIcon ? ""
, screenshots ? { }, homepage ? "", sourceUrl ? "", ...
}@rest:

let
  pkgs = import nixpkgs { inherit system; };

  pkgsCross = import nixpkgs {
    inherit system;
    crossSystem = nixpkgs.lib.systems.examples.arm-embedded;
  };

  nodeEnv = (pkgs.callPackage ./nodeEnv { }).nodeDependencies;
  pythonEnv = pkgs.python2.withPackages (ps: with ps; [ freetype-py sh pypng ]);

  pebble-sdk = pkgs.fetchzip {
    url = "https://binaries.rebble.io/sdk-core/release/sdk-core-4.3.tar.bz2";
    sha256 = "0p6x76rq5v9rb3j2fjdz1s2553n1yf5v2yhzxxp7g5220hmsk40j";
  };

  stringNotEmpty = str: builtins.isString str && str != "";
  pathInSrc = path: builtins.pathExists (src + path);

  metaYaml = with pkgs.lib;
    let
      screenshotPaths = builtins.concatLists (attrValues screenshots);
      assets = let
        allDeviceUrls = if screenshots ? all then screenshots.all else [ ];
        devices = removeAttrs screenshots [ "all" ];
      in builtins.concatStringsSep "\n" (mapAttrsToList (name: urls: ''
        - name: ${name}
          screenshots:
        ${builtins.concatStringsSep "\n"
        (map (url: "    - ${url}") urls ++ allDeviceUrls)}
      '') devices);

      categoryMap = {
        "Daily" = "5261a8fb3b773043d500000c";
        "Tools & Utilities" = "5261a8fb3b773043d500000f";
        "Notifications" = "5261a8fb3b773043d5000001";
        "Remotes" = "5261a8fb3b773043d5000008";
        "Health & Fitness" = "5261a8fb3b773043d5000004";
        "Games" = "5261a8fb3b773043d5000012";
      };
      categoryProp = if builtins.hasAttr category categoryMap then
        categoryMap.${category}
      else
        "Faces";

      indentString = str:
        "  " + (builtins.replaceStrings [ "\n" ] [ "\n  " ] str);
    in assert asserts.assertMsg (stringNotEmpty name) "name cannot be empty";
    assert asserts.assertMsg (stringNotEmpty description)
      "description cannot be empty";
    assert asserts.assertMsg (stringNotEmpty releaseNotes)
      "releaseNotes cannot be empty";
    assert asserts.assertOneOf "type" type [ "watchface" "watchapp" ];
    assert if type == "watchapp" then
      let
        validCategories = builtins.attrNames categoryMap;
      in if elem category validCategories then
        true
      else
        builtins.trace "category must be one of ${
          generators.toPretty { } validCategories
        }, but is ${generators.toPretty { } category}" false
    else
      true;
    assert if type == "watchapp" then
      asserts.assertMsg (stringNotEmpty banner) "banner must point to a file"
    else
      true;
    assert if type == "watchapp" then
      asserts.assertMsg (stringNotEmpty largeIcon)
      "largeIcon must point to a file"
    else
      true;
    assert if type == "watchapp" then
      asserts.assertMsg (stringNotEmpty smallIcon)
      "smallIcon must point to a file"
    else
      true;
    assert asserts.assertMsg ((builtins.length screenshotPaths) > 0)
      "At least 1 screenshot must be provided";
    builtins.toFile "meta.yml" ''
      pbw_file: ${name}.pbw
      header: ${banner}
      description: |
      ${indentString description}
      assets:
      ${assets}
      category: ${categoryProp}
      title: ${name}
      source: ${sourceUrl}
      type: ${type}
      website: ${homepage}
      release_notes: |
      ${indentString releaseNotes}
      small_icon: ${smallIcon}
      large_icon: ${largeIcon}
    '';
in pkgsCross.gcc8Stdenv.mkDerivation ({
  name = builtins.replaceStrings [ " " ] [ "-" ] name;
  version = "1";

  inherit src;

  nativeBuildInputs = [ pebble-tool pkgs.nodejs pythonEnv ]
    ++ nativeBuildInputs;

  postUnpack = ''
    # Setup Pebble SDK
    export HOME=`pwd`/home-dir
    SDK_ROOT=$HOME/.pebble-sdk/SDKs/4.3
    mkdir -p $SDK_ROOT/sdk-core
    cp -r ${pebble-sdk}/* $SDK_ROOT/sdk-core
    ln -s $SDK_ROOT $SDK_ROOT/../current
    ln -s ${pythonEnv} $SDK_ROOT/.env
    ln -s ${nodeEnv}/lib/node_modules $SDK_ROOT/node_modules

    chmod -R u+w $HOME
  '' + postUnpack;

  buildPhase = ''
    pebble clean
    pebble build
  '';

  installPhase =
    let screenshotPaths = pkgs.lib.flatten (builtins.attrValues screenshots);
    in ''
      mkdir -p $out
      mkdir -p \
        ${
          builtins.concatStringsSep " "
          (map (path: "$out/${dirOf path}") screenshotPaths)
        } \
        $out/${dirOf banner} \
        $out/${dirOf largeIcon} \
        $out/${dirOf smallIcon}

      cp ${metaYaml} $out/meta.yml
      cp build/$(basename `pwd`).pbw "$out/${name}.pbw"
      ${builtins.concatStringsSep "\n"
      (map (path: "cp ${path} $out/${path}") screenshotPaths)}

    '' + pkgs.lib.optionalString (stringNotEmpty banner) ''
      cp ${banner} $out/${banner}
    '' + pkgs.lib.optionalString (stringNotEmpty largeIcon) ''
      cp ${largeIcon} $out/${largeIcon}
    '' + pkgs.lib.optionalString (stringNotEmpty smallIcon) ''
      cp ${smallIcon} $out/${smallIcon}
    '' + ''

      cd $out
      tar czf appstore-bundle.tar.gz *
    '';
} // (removeAttrs rest [
  "name"
  "src"
  "nativeBuildInputs"
  "postUnpack"
  "screenshots"
]))
