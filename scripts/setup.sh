#! /usr/bin/env bash

if [ "$(type realpath 2>/dev/null)" == true ]; then
  NIXPKGS_BASEPATH=$(readlink `dirname "$0"`)
else
  NIXPKGS_BASEPATH=$(ruby -e "puts File.expand_path('$(dirname "$0")')")
fi

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
IS_NIXOS=$(type nix-rebuild 2>/dev/null)
IS_DARWIN=false
CURRENT_HOSTNAME=$(hostname)

if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_DARWIN=true
fi

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

if [ "$IS_DARWIN" == true ]; then
  # Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
  echo "Closing any open System Preferences dialogues"
  osascript -e 'tell application "System Preferences" to quit'
fi

# Give the computer a name
read -p "Pick a name for this machine [$(hostname)]:  " COMPUTER_NAME
if [ -z "$COMPUTER_NAME" ]; then
  COMPUTER_NAME=$(hostname)
fi
echo -e "Using "$GREEN"$COMPUTER_NAME"$ESC" for this machine"

nixConfig="$NIXPKGS_BASEPATH/hosts/$COMPUTER_NAME/configuration.nix"
if [ ! -f "$nixConfig" ]; then
  mkdir -p $(dirname "$nixConfig")
  echo "{}" > "$nixConfig"
fi

if [ "$IS_DARWIN" == true ]; then
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
  # Play user interface sound effects
  defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -bool false
  # Alert volume
  # Slider level:
  #  "75%": 0.7788008
  #  "50%": 0.6065307
  #  "25%": 0.4723665
  defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.000

  # Enable the Apple firewall
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool true
  sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true
  sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
  # Set Apple spaces to span multiple displays
  defaults write com.apple.spaces spans-displays -bool true

  # Display login window as: Name and password
  sudo defaults write /Library/Preferences/com.apple.loginwindow "SHOWFULLNAME" -bool true
  # Disable automatic login
  sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null
  # Allow guests to login to this computer
  sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
  # Show password hints after count (0 to disable)
  defaults write NSGlobalDomain RetriesUntilHint -int 0

  # Require password 5 seconds after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -bool true
  defaults write com.apple.screensaver askForPasswordDelay -int 5

  # Disable automatic login
  sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &> /dev/null

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Allow applications downloaded from anywhere
  sudo spctl --master-disable

  # Disable Infared Remote
  sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
else
  sudo sed -i "s/$CURRENT_HOSTNAME/$COMPUTER_NAME/g" /etc/hostname
  sudo sed -i "s/$CURRENT_HOSTNAME/$COMPUTER_NAME/g" /etc/hosts
  sudo hostname "$COMPUTER_NAME"
fi

# Nix
if [[ ! $NIX_EXISTS ]]; then
  curl -L https://nixos.org/nix/install | sh

  if [ ! -e /run ]; then
    sudo ln -s /private/var/run /run
  fi

  # Create this empty directory to prevent warnings coming from nix
  mkdir -p /nix/var/nix/profiles/per-user/root/channels

  NIX_INIT_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
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
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# nix darwin
if [[ ! $NIX_DARWIN_EXISTS ]] && [ "$IS_DARWIN" == true ]; then
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

if [ "$IS_DARWIN" == true ]; then
  darwin-rebuild switch
elif [ "$IS_NIXOS" == true ]; then
  nix-rebuild switch
else
  # this is for installs that are hosted on another linux distro
  # see ./config.nix for the configuration
  nix-env -iA nixpkgs.userConfiguration

  # need to manually run home-manager in this case too
  nix-shell '<home-manager>' -A install

  homeConfigPath='/home/simon/.config/nixpkgs/home.nix'
  replacementImports='imports = [ ../../.nixpkgs/home-configs/default.nix ];'

  if [[ ! $(grep -q "home-configs/default.nix" "$homeConfigPath") ]]; then
    sed -i "s|^\}|  ${replacement}\n}|g" "$homeConfigPath"
  fi

  home-manager switch
fi
echo -e ""$GREEN"Successfully completed!"$ESC""
echo "Restart your machine for GPG/keyring to be setup properly"

if [ "$IS_DARWIN" == true ]; then
  # re-enable IPV6 now we have a decent curl from nixpkgs
  sudo networksetup -setv6automatic Wi-Fi &>/dev/null
  sudo networksetup -setv6automatic Ethernet &>/dev/null
fi
