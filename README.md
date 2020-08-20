# pebble.nix

Tools for building Pebble apps on Nix systems

## Quickstart

**Recommended:** Install [Cachix](https://cachix.org/) and use the `pebble`
cache. Using Cachix is highly recommended, as building some required derivations
(qemu-pebble, the ARM toolchain) locally can take a long time. Cachix provides
prebuilt, binary backages so you don't have to do the building.

On non-NixOS systems:
```shell
nix-env -i cachix
```

On NixOS, add `cachix` to `environment.systemPackages` in your configuration.

Finally, to use the pebble.nix cache (you might need to run this command with
`sudo` if your user isn't a trusted user in the Nix daemon):
```shell
cachix use pebble
```

### Development Shell

A development shell provides you with a shell containing the `pebble` tool and
the Pebble emulator. To set it up in your project, create a `shell.nix` file
with the following content in the root of your project:

```nix
(import
  (builtins.fetchTarball https://github.com/Sorixelle/pebble.nix/archive/master.tar.gz)
).devShell { }
```

Then, run `nix-shell` to open up a shell with all the tools for Pebble
development.

### Build for App Store

`pebble.nix` can build your watchapp or watchface, and package it in a bundle
ready for deployment to the Rebble App Store. Create a `default.nix` file in the
root of your project with the following content, and change the properties for
your project:

```nix
(import
  (builtins.fetchTarball https://github.com/Sorixelle/pebble.nix/archive/master.tar.gz)
).buildPebbleApp {
  name = "App Name";
  src = ./.;
  type = "watchface";

  description = ''
    Your app description here.
  '';

  releaseNotes = ''
    Initial release.
  '';

  screenshots = {
    aplite = [ "assets/screenshots/aplite/screenshot.png" ];
    basalt = [ "assets/screenshots/basalt/screenshot.png" ];
    chalk = [ "assets/screenshots/chalk/screenshot.png" ];
    diorite = [ "assets/screenshots/diorite/screenshot.png" ];
  };
}
```

To build the bundle, run `nix-build`. The bundle will be output to
`result/appstore-bundle.tar.gz`.

### Flake Support

`pebble.nix` can be consumed as a flake, if you're using flakes in your project.
You can use it with a `flake.nix` similar to the following:

```nix
{
  inputs.pebble.url = github:Sorixelle/pebble.nix;

  outputs = { self, pebble }: {
    devShell.${system} = pebble.devShell.${system} { };

    defaultPackage.${system} = pebble.buildPebbleApp.${system} { ... };
  };
}
```

### Pinning

Using `builtins.fetchTarball` only caches a tarball for an hour by default. If
you don't want to have to redownload pebble.nix every hour, you can pin to a
specific commit.

```nix
builtins.fetchTarball {
  # Get the desired commit hash at https://github.com/Sorixelle/pebble.nix/commits
  url = https://github.com/Sorixelle/pebble.nix/archive/<commitHash>.tar.gz;
  # Get the hash by running "nix-prefetch-url --unpack <url>" on the tarball url
  sha256 = "<tarballHash>";
}
```

This is unnecessary if you're using flakes - flakes pin other flakes
automatically.

## Usage

### Development shells

Development shells can be configured by specifying the following arguments to
`devShell`:

- `devServerIP`: The default development server IP. You can find this in the
  Pebble app.
- `emulatorTarget`: The default target to start the Pebble emulator for.
- `nativeBuildInputs`: Any extra tools to use during development.

### App Store Builds

`buildPebbleApp` requires a few specific attributes to create the metadata YAML
file the Rebble App Store uses to create your app's page.

- `name`: The name of your app.
- `type`: The type of app. Must be either `watchapp` or `watchface`.
- `description`: A description of your app.
- `releaseNotes`: The release notes for this version of your app.
- `category`: The category of your app. Only needed for watchapps. The valid
   values are:
   - Daily
   - Tools & Utilities
   - Notifications
   - Remotes
   - Health & Fitness
   - Games
- `banner`: Path to a 720x320 image that will be displayed as the banner for
  your app. Optional for watchfaces.
- `smallIcon`: Path to a 48x48 icon for your app. Optional for watchfaces.
- `largeIcon`: Path to a 144x144 icon for your app. Optional for watchfaces.
- `homepage`: A URL to the homepage for your app. Optional.
- `sourceUrl`: A URL to the source code of your app. Optional.
- `screenshots`: An attribute set containing screenshots of your app on Pebble
  watches. Each attribute contains a list of paths to screenshots. At least 1
  screenshot in total must be provided. The following attributes are valid:
  - `aplite`: Screenshots for the aplite platform (Pebble, Pebble Steel)
  - `basalt`: Screenshots for the basalt platform (Pebble Time, Pebble Time
     Steel)
  - `chalk`: Screenshots for the chalk platform (Pebble Time Round)
  - `diorite`: Screenshots for the diorite platform (Pebble 2, Pebble 2 HR)
  - `all`: Screenshots to be used for all platforms.

Other options relating to the build process:

- `src`: Path to the project root. Usually `./.` (the same folder your Nix
  expression is in).
- `nativeBuildInputs`: Any extra tools/dependencies to be used at build time.
