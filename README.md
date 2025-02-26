# pebble.nix

[![CI status badge](https://github.com/Sorixelle/pebble.nix/actions/workflows/buildAndCache.yml/badge.svg)](https://github.com/Sorixelle/pebble.nix/actions/workflows/buildAndCache.yml?query=branch%3Amain)

A collection of tools for setting up Pebble app development environments, and building Pebble apps/watchfaces, using
[Nix](https://nixos.org/).

## Getting Started

### Step 1: Install Nix

Nix is the build system that underlies pebble.nix - you'll need to have it installed on your system to use it. There's a
few ways to install Nix out there - if you don't have an install, I recommend one of the following:

- [Lix Installer](https://lix.systems/install/#on-any-other-linuxmacos-system)
- [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer#install-nix)

There's very little difference between the two - Lix is [a fork of Nix](https://lix.systems/about/) focused on language
stability and improving the developer experience, while still remaining compatible with upstream Nix (which is what the
Determinate Nix Installer sets up). pebble.nix fully supports both implementations, so take your pick!

You might wonder - why not use the official Nix installer? There's a few rough edges in it that require manual fixup
after installation to workaround (doesn't allow using Nix flakes out-of-the-box, lack of Fish shell support, etc.). The
installers listed above don't have these problems, so it's easier to use them instead.

### Step 2: Install Cachix (optional, but recommended)

The job of pebble.nix is to give Nix instructions on how to build and compile all the pieces needed to get a full Pebble
SDK and developer tool setup. Compiling everything can take a very long time on some systems, so to cut down on initial
setup time, you can use [Cachix](https://cachix.org) to download prebuilt versions of tools from a binary cache, instead
of compiling everything on your system.

If you're on NixOS, you can install Cachix through the usual mechanisms there. Otherwise, Cachix can be installed by
running:
```shell
nix-env -iA cachix
```

Once it's installed, you'll need to use it to add the binary cache to your Nix setup. On non-NixOS systems, you just
need to run the following command:
```shell
cachix use pebble
```

On NixOS systems, that command will add the cache to your NixOS configuration - make sure you rebuild the system for the
change to take effect.

### Step 3: Create a new project

Normally, to create a new Pebble project, you'd run `pebble new-project <name>`. But we don't have the Pebble tools
installed yet - instead, we need to run the Pebble tool from pebble.nix. `nix run` allows you to run any program in a
Nix derivation defined in a GitHub repo without installing it - we can use it to bootstrap a new project. In the folder
you want to keep your project in, run the following command:

```shell
nix run github:Sorixelle/pebble.nix#pebble-tool -- new-project <project name>
```

You now have a new Pebble app project, in a folder with the same name as the project name! The `nix run` command
effectively acts as a substitute for the `pebble` command, where everything after `--` gets passed as arguments to
`pebble`. For example, if you wanted to list all the available Pebble SDK versions, you could run:

```shell
nix run github:Sorixelle/pebble.nix#pebble-tool -- sdk list
```

Having to type out that full command every time is a bit annoying, though. Also, trying to build the app doesn't work,
since there's no ARM compiler setup. We can fix both of those problems by using a development shell.

### Step 4: Create a development shell

Development shells are a feature of Nix, that let you specify a list of packages that you want to temporarily install.
You can then "enter" that development shell by running `nix develop`, which will run a new shell process that has all of
the packages you specified installed and ready to use. As soon as you `exit` the development shell, all those packages
are removed from your shell session, until you enter the development shell again.

In Nix, development shells are specified in a flake. Without going into too much detail, a flake is a `flake.nix` file
at the root of your project that defines all the Nix-related bits of your project - the development shell, any Nix
packages you create, plus a bunch of other things that aren't important to us. What we want is a development shell that
has everything we'll want when writing a Pebble app. pebble.nix has a function called `pebbleEnv` that has all of that
stuff included - we just need to create a flake that tells Nix to use `pebbleEnv` for our project's devshell.

pebble.nix provides a template for setting up a flake with a development shell in an existing project. To use that
template, run:

```shell
nix flake init -t github:Sorixelle/pebble.nix
```

You should now have a `flake.nix` file in your project with a development shell ready to use. To ender the shell, run
`nix develop` in the project. You'll be dropped into a new shell session, that has everything you need to build Pebble
apps - the `pebble` tool, the emulator, and an ARM compiler! You can use the `pebble` tool exactly like you would in a
normal install while you're in here.

You'll notice a `flake.lock` file was created after running `nix develop`. That file makes sure none of the flake's
inputs (such as pebble.nix) update out of nowhere and potentially break your setup, similarly to things like npm's
`package-lock.json`. If you do want to update, you can use `nix flake update` to get the latest versions of your flake's
inputs. If you make a Git repo in your project, don't forget to commit the `flake.lock` file!

### Step 5: Setup nix-direnv (optional, but recommended)

Having to run `nix develop` every time you want to use the Pebble tools is a bit annoying. In the Nix ecosystem, there's
a tool called [direnv](https://direnv.net/) that automatically sets up environment variables when you `cd` into a
directory. [nix-direnv](https://github.com/nix-community/nix-direnv) integrates direnv with Nix development shells,
letting you enter and exit a development shell just by `cd`ing in and out of the folder - no more forgetting to `nix
develop`!

First, setup direnv using their [install guide](https://direnv.net/docs/installation.html) (don't forget the shell hook
step!). Once it's setup, we can create a `.envrc` file in our project that tells direnv what to do when we enter the
directory. We want it to open the development shell, which we can do by pasting the following shell script into the
file:
``` shell
# Make sure nix-direnv is setup
if ! has nix_direnv_version || ! nix_direnv_version 3.0.6; then
  source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.6/direnvrc" "sha256-RYcUJaRMf8oF5LznDrlCXbkOQrywm0HDv1VjYGaJGdM="
fi

# Activate the developer shell
use flake
```

After saving that file, direnv will prompt you to allow it to run in that folder (it's a security mechanism, to make
sure you don't unwittingly run potentially malicious code by entering a folder you downloaded with a `.envrc` file) by
running `direnv allow`. Once done, the development shell will be active, and all the Pebble tools will be ready to go as
soon as you open your project!

Most code editors have a direnv plugin available (eg.
[VSCode](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv), [Vim](https://github.com/direnv/direnv.vim),
[Emacs](https://github.com/wbolster/emacs-direnv)), so you can use the Pebble tools in your editor's integrated
build/debug support.

### Step 6: Build your project with Nix (optional)

TODO

## Usage

### Development shells

Development shells can be configured by specifying the following arguments to `pebbleEnv`:

- `devServerIP`: The default development server IP. You can find this in the Pebble app.
- `emulatorTarget`: The default target to start the Pebble emulator for.
- `cloudPebble`: Whether to connect via a CloudPebble connection. Requires logging into Rebble via `pebble login`.
- `nativeBuildInputs`: Any extra tools to use during development.
- `CFLAGS`: Extra flags to pass to the compiler during app builds.

### App Store Builds

`buildPebbleApp` requires a few specific attributes to create the metadata YAML file the Rebble App Store uses to create
your app's page.

- `name`: The name of your app.
- `type`: The type of app. Must be either `watchapp` or `watchface`.
- `description`: A description of your app.
- `releaseNotes`: The release notes for this version of your app.
- `category`: The category of your app. Only needed for watchapps. The valid values are:
   - Daily
   - Tools & Utilities
   - Notifications
   - Remotes
   - Health & Fitness
   - Games
- `banner`: Path to a 720x320 image that will be displayed as the banner for your app. Optional for watchfaces.
- `smallIcon`: Path to a 48x48 icon for your app. Optional for watchfaces.
- `largeIcon`: Path to a 144x144 icon for your app. Optional for watchfaces.
- `homepage`: A URL to the homepage for your app. Optional.
- `sourceUrl`: A URL to the source code of your app. Optional.
- `screenshots`: An attribute set containing screenshots of your app on Pebble watches. Each attribute contains a list
  of paths to screenshots. At least 1 screenshot in total must be provided. The following attributes are valid:
  - `aplite`: Screenshots for the aplite platform (Pebble, Pebble Steel)
  - `basalt`: Screenshots for the basalt platform (Pebble Time, Pebble Time Steel)
  - `chalk`: Screenshots for the chalk platform (Pebble Time Round)
  - `diorite`: Screenshots for the diorite platform (Pebble 2, Pebble 2 HR)
  - `all`: Screenshots to be used for all platforms.

Other options relating to the build process:

- `src`: Path to the project root. Usually `./.` (the same folder your Nix expression is in).
- `nativeBuildInputs`: Any extra tools/dependencies to be used at build time.
