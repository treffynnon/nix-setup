#! /usr/bin/env bash

# kitty uses something like xterm-kitty, which nix does not recognise so this will allow
# kitty masquerade as xterm-256color for the purposes of this setup script
if [[ "$TERM" = *"kitty"* ]]; then
  TERM=xterm-256color
fi

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

NIX_EXISTS=$(type nix-env 2>/dev/null) 
NIX_DARWIN_EXISTS=$(type darwin-rebuild 2>/dev/null) 

# Ensure script is not being run with root privileges
if [ $EUID -eq 0 ]; then
  echo "Please don't run this script with root privileges!"
  exit 1
fi

SUDO_ON=$(sudo -n command &>/dev/null; echo $?)
if [ $SUDO_ON -gt 0 ]; then
  echo "Some of the operations must be run as admin so please enter your admin password: "
  sudo -v
fi

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
echo "Closing any open System Preferences dialogues"
osascript -e 'tell application "System Preferences" to quit'

# Give the computer a name
read -p "Pick a name for this machine [$(hostname)]:  " COMPUTER_NAME
if [ -z "$COMPUTER_NAME" ]; then
  COMPUTER_NAME=$(hostname)
fi
echo -e "Using "$GREEN"$COMPUTER_NAME"$ESC" for this machine"

nixConfig="./hosts/$COMPUTER_NAME/configuration.nix"
if [ ! -f "./hosts/$COMPUTER_NAME/configuration.nix" ]; then
  mkdir -p $(dirname "$nixConfig")
  echo "{}" > "$nixConfig"
fi

# the version of curl that comes with macosx is ancient cannot deal with IPV6 addresses
# so need disable them for now. Seems be an issue on some corporate networks for some reason.
sudo networksetup -setv6off Wi-Fi &>/dev/null
sudo networksetup -setv6off Ethernet &>/dev/null

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
dscacheutil -flushcache

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Nix
if [[ ! $NIX_EXISTS ]]; then
  curl https://nixos.org/nix/install | sh

  if [ ! -e private/var/run ]; then
    sudo ln -s private/var/run /run
  fi

  # Create this empty directory to prevent warnings coming from nix
  mkdir -p /nix/var/nix/profiles/per-user/root/channels

  NIX_INIT_SCRIPT="$HOME/.nix-profile/etc/profile.d/nix.sh"
  if [ -f $NIX_INIT_SCRIPT ]; then
    source "$NIX_INIT_SCRIPT"
  else
    echo -e ""$RED"Nix doesn't appear to have been installed correctly. Aborting!"$ESC""
    echo "$NIX_INIT_SCRIPT should exist and be executable - please try again."
    exit 1
  fi

  NIX_EXISTS=$(type nix-env 2>/dev/null)

  # Ensure Nix has already been installed
  if [[ ! $NIX_EXISTS ]]; then
    echo -e "Cannot find "$YELLOW"nix-env"$ESC" in the PATH"
    echo "This means that the nix init script has not been sourced properly"
    exit 1
  fi
fi


# sets the host for the nix/hostname.nix script to pick up instead of asking the system for it
# this is because the host may not be fully setup until after a reboot occurs
export HOST="$COMPUTER_NAME"

if [ ! -L /etc/shells -a -f /etc/shells ]; then
  sudo mv /etc/shells /etc/shells.bak
fi
if [ ! -L /etc/zprofile -a -f /etc/zprofile ]; then
  sudo mv /etc/zprofile /etc/zprofile.local
fi
if [ ! -L /etc/zshrc -a -f /etc/zshrc ]; then
  sudo mv /etc/zshrc /etc/zshrc.local
fi

# home-manager
nix-channel --add https://github.com/rycee/home-manager/archive/release-19.09.tar.gz home-manager
nix-channel --update

# nix darwin
if [[ ! $NIX_DARWIN_EXISTS ]]; then
  nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
  ./result/bin/darwin-installer

  NIX_DARWIN_EXISTS=$(type darwin-rebuild 2>/dev/null)

  # Ensure nix-darwin has already been installed
  if [[ ! $NIX_DARWIN_EXISTS ]]; then
    echo -e "Cannot find "$YELLOW"darwin-rebuild"$ESC" in the PATH"
    echo "This means that the nix-darwin init script has not been sourced properly"
    exit 1
  fi
fi

NIX_SUPPLIED_BASH="/run/current-system/sw/bin/bash"
if [[ "$SHELL" != "/run"* && "$SHELL" != "/nix"* && -L "$NIX_SUPPLIED_BASH" ]]; then
  echo "Switching default shell to newer nix supplied bash"
  chsh -s "$NIX_SUPPLIED_BASH"
  export SHELL="$NIX_SUPPLIED_BASH"
fi

darwin-rebuild switch
echo -e ""$GREEN"Successfully completed!"$ESC""
echo "Restart your machine for GPG/keyring to be setup properly"

# re-enable IPV6 now we have a decent curl from nixpkgs
sudo networksetup -setv6automatic Wi-Fi &>/dev/null
sudo networksetup -setv6automatic Ethernet &>/dev/null
