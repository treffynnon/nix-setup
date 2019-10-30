#! /usr/bin/env bash

# ANSI properties/colours
ESC='\033[0m'
BLUE='\033[38;34m'
BLUE_UL='\033[38;4;34m'
GREEN='\033[38;32m'
GREEN_UL='\033[38;4;32m'
RED='\033[38;31m'
RED_UL='\033[38;4;31m'
YELLOW='\033[38;33m'
YELLOW_UL='\033[38;4;33m'

# Give the computer a name
read -p "Pick a name for this machine [$(hostname)]:  " COMPUTER_NAME
if [ -z "$COMPUTER_NAME" ]; then
  COMPUTER_NAME=$(hostname)
fi
echo -e "Using "$BLUE"$COMPUTER_NAME"$ESC" for this machine"

nixConfig="./hosts/$COMPUTER_NAME/configuration.nix"
if [ ! -f "./hosts/$COMPUTER_NAME/configuration.nix" ]; then
  mkdir -p $(dirname "$nixConfig")
  echo "{}" > "$nixConfig"
fi

# Ask for the administrator password upfront
echo "Some of the operations must be run as admin so please enter your admin password."
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# the version of curl that comes with macosx is ancient cannot deal with IPV6 addresses so need disable them for now
networksetup -setv6off Wi-Fi &>/dev/null
networksetup -setv6off Ethernet &>/dev/null

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
dscacheutil -flushcache

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Nix
#curl https://nixos.org/nix/install | sh

# Create this empty directory to prevent warnings coming from nix
mkdir -p /nix/var/nix/profiles/per-user/root/channels
sudo ln -s private/var/run /run

NIX_INIT_SCRIPT="$HOME/.nix-profile/etc/profile.d/nix.sh"
if [ -f $NIX_INIT_SCRIPT ]; then
  source /Users/simon/.nix-profile/etc/profile.d/nix.sh
else
  echo -e ""$RED"Nix doesn't appear to have been installed correctly. Aborting!"$ESC""
  echo "$NIX_INIT_SCRIPT should exist and be executable - please try again."
  exit
fi

# sets the host for the nix/hostname.nix script to pick up instead of asking the system for it
# this is because the host may not be fully setup until after a reboot occurs
export HOST="$COMPUTER_NAME"

if [ -f /etc/shells ]; then
  sudo mv /etc/shells /etc/shells.bak
fi
if [ -f /etc/zprofile ]; then
  sudo mv /etc/zprofile /etc/zprofile.local
fi
if [ -f /etc/zshrc ]; then
  sudo mv /etc/zshrc /etc/zshrc.local
fi

# setup the nix-daemon users - without these nix-darwin will refuse to complete its setup steps
curl -L -o bootstrap.sh https://raw.githubusercontent.com/LnL7/nix-darwin/master/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh -u
rm bootstrap.sh

# home-manager
nix-channel --add https://github.com/rycee/home-manager/archive/release-19.09.tar.gz home-manager
nix-channel --update

if [ -L /run/current-system/sw/bin/bash ]; then
  echo "Switching default shell to newer nix supplied bash"
  chsh -s /run/current-system/sw/bin/bash
fi

# re-enable IPV6 now we have a decent curl from nixpkgs
networksetup -setv6automatic Wi-Fi &>/dev/null
networksetup -setv6automatic Ethernet &>/dev/null

if [[ $(type darwin-rebuild 2>/dev/null) ]]; then
  echo -e ""$GREEN"Successfully completed!"$ESC""
  echo "Restart your machine for GPG/keyring to be setup properly"
fi
