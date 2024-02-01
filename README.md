# Getting started

Clone this repo to `~/.nixpkgs` and run the setup script:

    git clone git@github.com:treffynnon/nix-setup.git ~/.nixpkgs && ~/.nixpkgs/scripts/setup.sh

which will perform the following actions for you:

1.  Install [nix](https://nixos.org/nix/download.html)
2.  if on a Mac install
    [nix-darwin](https://github.com/LnL7/nix-darwin#install)
3.  install
    [home-manager](https://rycee.gitlab.io/home-manager/index.html#sec-install-standalone)
4.  back-up `/etc/shells`
5.  moves default ZSH zprofile and zshrc to \*.local (they still get
    loaded!)
6.  runs `darwin-rebuild switch` to install all the dependencies with
    nix

## Rebuilding the configuration when you change the files

    TERM=xterm-256color darwin-rebuild switch

The TERM environment var is changed here because modern term emulators
like kitty confuse the darwin-rebuild util.

## Setup cachix

### Install to benefit from the binary cache

Install the cachix package to the environment

    nix-env -iA cachix -f https://cachix.org/api/v1/install

Configure cachix to be used

    cachix use treffynnon

This will use the binaries I have cached there were it can instead of
spending time recompiling them on your machine. It is also used by
GitHub Actions to speed up the linting/formatting/testing builds.

### Pushing to the binary cache

Setup the necessary keys

    cachix generate-keypair treffynnon

Set the signing key in `~/.config/cachix/cachix.dhall` where it should
be set against the `secretKey` property. If you’re not me then you’ll
need to create your own cache on <https://cachix.org> first as you
cannot push to my cache - yoo can read from it, but not push to it.

You can now push binary builds to the cachix repository.

    cachix push treffynnon <path to some package in /nix/store>

## Setup bash completions

For bash completions to work properly the system must use the nix
supplied version of bash as the MacOS version is ancient.

    chsh -s /run/current-system/sw/bin/bash

If you want to use Fish shell then:

    chsh -s /run/current-system/sw/bin/fish

See
<https://discourse.nixos.org/t/using-nix-to-install-login-shell-on-non-nixos-platform/2807/3>

## GPG setup

For the SSH agent and git commits to work the GPG signing key must be
present. If you have already got one then import it:

    gpg --import /path/to/your.key

Otherwise you can create one using this comprehensive guide -
<https://blog.tinned-software.net/create-gnupg-key-with-sub-keys-to-sign-encrypt-authenticate/>

## Setting up hammerspoon

Install Hammerspoon from <https://www.hammerspoon.org/>

Hammerspoon provides:

- Window management via the keyboard
- kbd:\[Caps lock\] as kbd:\[Esc\] when tapped and kbd:\[Ctrl\] when
  held

Run Hammerspoon (use Spotlight with kbd:\[Command\] + kbd:\[Space\]) -
note that it can take sometime to start initially - be patient - and
configure it to:

- Run at login
- Enable Accessibility
- (optionally) untick "Show dock icon"

The configuration is in `./home-configs/hammerspoon.nix` and
`./home-configs/hammerspoon`.

## Environment variables

Private or secret environment vars you don’t want to commit into a
repository can be stored in ~/.env with the following format.

    MY_VAR=MY_VALUE

# Uninstalling

You can reverse the setup process by running the remove script:

    ./scripts/remove.sh

# Making changes

## Building the code

If you modify any of the configurations in the nix configuration then
you need to rebuild the environment.

    darwin-rebuild switch

It will probably ask you to enter a password, which can get annoying so
you can modify the sudoers file to allow passwordless invocation of
`darwin-rebuild` for your user. Create a `/etc/sudoers.d/nix-darwin`
file with this content:

    <home-user> ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild (where home-user is name of home directory)

## Formatting code

This project uses:

- [alejandra](https://github.com/kamadorueda/alejandra)
- [statix](https://github.com/nerdypepper/statix)
- [LuaFormatter](https://github.com/Koihik/LuaFormatter)
- [luacheck](https://github.com/mpeterv/luacheck)

to keep the code and configurations in a consistent state. They are also
applied as a github action to test the setup in CI too.

To easily run the formatters locally you can use the supplied
`nix-shell`:

    nix-shell
    ./codestyle/format.sh

# Managing development environments

## Direnv and Lorri

**I no longer use lorri because I am using nix-direnv instead.**

Install [Lorri](https://github.com/target/lorri) (not currently a Nix
package due to their rapid development cycles while in beta).

Put a .envrc file inside your project with:

**.envrc**

    eval "$(lorri direnv)"

and a file for the nix-shell (`shell.nix`):

    let
      # nix1809 = import (builtins.fetchGit {
      #   name = "nixos-18_09";
      #   url = https://github.com/NixOS/nixpkgs.git;
      #   ref = "refs/tags/18.09";
      # }) {};
      nix1809 = import (
        builtins.fetchTarball {
          name = "nixos-18_09";
          url = "https://github.com/NixOS/nixpkgs/archive/18.09.tar.gz";
          sha256 = "1ib96has10v5nr6bzf7v8kw7yzww8zanxgw2qi1ll1sbv6kj6zpd";
        }
      ) {};
    in
      with import <nixpkgs> {};
        stdenv.mkDerivation {
          name = "ftr-beast";
          buildInputs = [
            bashInteractive
            nix1809.nodejs-8_x
          ];
        }

Start lorri with `lorri daemon` and leave it running in a shell.

Now when you cd into the projects directory Lorri/direnv will install
the dependencies and drop you into a Nix shell.

# MacOS Catalina

Before upgrading to Catalina:

- <https://gist.github.com/chrisandreae/e61e06f08ec0a650a0b3b41788d41724>
- <https://github.com/NixOS/nix/issues/2925>

# Useful links

## Nix

- <https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-writeScriptBin>
- <https://github.com/nmattia/homies/blob/master/git/default.nix>
- <https://github.com/rummik/nixos-config/blob/master/config/nodejs.nix>
- <https://discourse.nixos.org/t/bootstrapping-new-system/3455/9>
- <https://nixos.org/nix/manual/#ssec-builtins>
- <https://rycee.gitlab.io/home-manager/options.html>
- <https://medium.com/@ejpcmac/about-using-nix-in-my-development-workflow-12422a1f2f4c>
- <https://github.com/direnv/direnv#setup>
- <https://wiki.nikitavoloboev.xyz/package-managers/nix/nix-darwin>
- <https://www.softinio.com/post/moving-from-homebrew-to-nix-package-manager/>
- <http://chriswarbo.net/git/nix-helpers/git/branches/master/index.html>
- <http://chriswarbo.net/projects/nixos/useful_hacks.html>
- <https://github.com/samdroid-apps/nix-articles>
- <https://matthewbauer.us/blog/all-the-versions.html>

### Flakes

- <https://nixos.wiki/wiki/Flakes>
- <https://fasterthanli.me/series/building-a-rust-service-with-nix/part-10>
- <https://determinate.systems/posts/nix-github-actions>
- <https://nixos-and-flakes.thiscute.world>
- <https://www.tweag.io/blog/2020-05-25-flakes>
- <https://zero-to-nix.com>
- <https://github.com/dustinlyons/nixos-config>

### Lua and nix

- <https://github.com/NixOS/nixpkgs/pull/55302/files>

### Dot files managed by nix

- <https://github.com/danieldk/nix-home/tree/master/cfg>
- <https://github.com/jwiegley/nix-config/blob/master/overlays/30-apps.nix>
- <https://github.com/Jomik/dotfiles/tree/master/.config/nixpkgs>
- <https://rycee.net/posts/2017-07-02-manage-your-home-with-nix.html>

### Building C/C++ projects with nix

- <https://gist.github.com/CMCDragonkai/41593d6d20a5f7c01b2e67a221aa0330>

## OSX

### OSX settings values

- <https://gist.github.com/smgt/3227665> - list of OSX settings
- <https://github.com/joeyhoer/starter/tree/master/system> and
  <https://github.com/joeyhoer/starter/tree/master/apps> \*

### OSX security settings

- <http://macos.duh.to/#application-layer-firewall>

### OSX screen management woes

#### OSX multiple monitors losing position and rotation settings

- <https://apple.stackexchange.com/questions/42835/primary-display-randomly-changes/296905#296905>
- <https://github.com/lucasvickers/osx-display-positioner>
- <https://superuser.com/questions/1105308/mac-3-monitor-setup-my-desktop-set-keep-switching-places-between-monitors/1220526>
- <https://apple.stackexchange.com/questions/249865/set-position-of-secondary-screen>

#### Spaces merging together on disconnecting additional monitors

- <https://superuser.com/questions/917958/how-can-i-stop-osx-from-combining-spaces-when-i-unplug-a-monitor>

# Todo

- <https://github.com/jasonrudolph/keyboard#features>

install confs for

- Karabiner-Elements
- Lulu - this has an interactive installer so probably too hard to do
  with nix
- Netiquette - this has an interactive installer so probably too hard
  to do with nix
