#!/usr/bin/env bash

# Modern Nix Configuration Setup Script
# Sets up flake-based Nix configuration with 1Password integration

set -euo pipefail

# Configuration validation
validate_nix_config() {
  echo "🔍 Validating Nix configuration..."
  if ! nix flake check --no-build "$NIXPKGS_BASEPATH" &>/dev/null; then
    echo -e "${RED}❌ Nix configuration validation failed${ESC}"
    echo "Please fix configuration errors before running setup"
    return 1
  fi
  echo "✅ Nix configuration is valid"
}

# Error recovery function
cleanup_on_error() {
  local exit_code=$?
  echo -e "${RED}❌ Setup failed with exit code $exit_code${ESC}"
  echo "Performing cleanup..."

  # Re-enable IPv6 if we disabled it
  if [ "$IS_DARWIN" == true ] && [ "${IPV6_DISABLED:-false}" == "true" ]; then
    sudo networksetup -setv6automatic Wi-Fi &>/dev/null || true
    sudo networksetup -setv6automatic Ethernet &>/dev/null || true
  fi

  exit $exit_code
}
trap cleanup_on_error ERR

# Progress tracking
TOTAL_STEPS=7
CURRENT_STEP=0

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo -e "${BLUE}[$CURRENT_STEP/$TOTAL_STEPS] $1${ESC}"
}

# Get the base path of the nixpkgs directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIXPKGS_BASEPATH="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# System detection
IS_DARWIN=false
IS_NIXOS=false
IPV6_DISABLED=false
CURRENT_HOSTNAME=$(hostname)

if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_DARWIN=true
fi

if [[ -f /etc/nixos/configuration.nix ]]; then
  IS_NIXOS=true
fi

# Check for required commands
NIX_EXISTS=$(command -v nix 2>/dev/null || echo "")
DARWIN_REBUILD_EXISTS=$(command -v darwin-rebuild 2>/dev/null || echo "")
NIXOS_REBUILD_EXISTS=$(command -v nixos-rebuild 2>/dev/null || echo "")

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

echo -e "${GREEN}🚀 Starting Modern Nix Configuration Setup${ESC}"
echo -e "Setting up flake-based configuration from: ${BLUE}$NIXPKGS_BASEPATH${ESC}"
echo

progress "Validating configuration"
# Validate configuration before starting setup
if command -v nix &>/dev/null; then
  validate_nix_config
fi

if [ "$IS_DARWIN" == true ]; then
  progress "macOS System Setup"

  # Install Xcode command line tools first
  echo "Installing Xcode command line tools..."
  if ! xcode-select --print-path &>/dev/null; then
    echo "Xcode command line tools not found. Installing..."
    xcode-select --install
    echo "Please wait for Xcode command line tools installation to complete,"
    echo "then press any key to continue..."
    read -n 1 -s
  else
    echo "✅ Xcode command line tools already installed"
  fi

  # Close any open System Preferences panes, to prevent them from overriding settings we're about to change
  echo "Closing any open System Preferences dialogues"
  osascript -e 'tell application "System Preferences" to quit'
fi

# Give the computer a name
progress "Setting up hostname and host configuration"
read -p "Pick a name for this machine [$(hostname)]: " COMPUTER_NAME
if [ -z "$COMPUTER_NAME" ]; then
  COMPUTER_NAME=$(hostname)
fi
echo -e "Using ${GREEN}$COMPUTER_NAME${ESC} for this machine"

# Create host-specific configuration if it doesn't exist
nixConfig="$NIXPKGS_BASEPATH/hosts/$COMPUTER_NAME/configuration.nix"
if [ ! -f "$nixConfig" ]; then
  echo "Creating host-specific configuration: $nixConfig"
  mkdir -p "$(dirname "$nixConfig")"

  # Detect appropriate state versions
  echo "🔍 Detecting appropriate state versions..."

  # Platform-specific detection
  if [ "$IS_NIXOS" == true ]; then
    echo "   Platform: NixOS"
    # For NixOS, try to detect current version
    if command -v nixos-version &>/dev/null; then
      DETECTED_VERSION=$(nixos-version 2>/dev/null | cut -d'.' -f1-2 2>/dev/null || echo "")
      if [ -n "$DETECTED_VERSION" ]; then
        SYSTEM_STATE_VERSION="\"$DETECTED_VERSION\""
        echo "   Detected NixOS version: $DETECTED_VERSION"
      else
        SYSTEM_STATE_VERSION="\"24.05\""  # Current stable as fallback
        echo "   Using current stable NixOS version: 24.05"
      fi
    else
      SYSTEM_STATE_VERSION="\"24.05\""  # Current stable as fallback
      echo "   Using current stable NixOS version: 24.05"
    fi
    HM_STATE_VERSION="24.05"
  else
    echo "   Platform: macOS (nix-darwin)"
    # For nix-darwin, use current stable version
    SYSTEM_STATE_VERSION="5"  # Current nix-darwin state version
    HM_STATE_VERSION="24.05"  # Current Home Manager stable
    echo "   Using current nix-darwin state version: 5"
  fi

  echo "✅ Final state versions:"
  echo "   System state version: $SYSTEM_STATE_VERSION"
  echo "   Home Manager state version: $HM_STATE_VERSION"

  cat > "$nixConfig" << EOF
{
  # Host-specific configuration for $COMPUTER_NAME
  networking.hostName = "$COMPUTER_NAME";

  # Set the state version based on when you first installed this system
  # NEVER change this unless you understand the migration implications
  system.stateVersion = $SYSTEM_STATE_VERSION;  # Auto-detected

  # Home Manager state version
  home-manager.users.simon.home.stateVersion = "$HM_STATE_VERSION";

  # Add any host-specific overrides here
}
EOF
  echo "✅ Created host configuration with auto-detected state versions"
else
  echo "✅ Host configuration already exists: $nixConfig"
fi

if [ "$IS_DARWIN" == true ]; then
  echo "🍎 Configuring macOS system settings..."

  # Disable IPv6 temporarily (some corporate networks have issues)
  echo "Temporarily disabling IPv6 for network compatibility..."
  sudo networksetup -setv6off Wi-Fi &>/dev/null && IPV6_DISABLED=true
  sudo networksetup -setv6off Ethernet &>/dev/null || true

  # Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
  dscacheutil -flushcache

  # macOS system preferences not handled by nix-darwin
  # (Most settings are now in darwin-configuration.nix)

  # Disable the sound effects on boot
  sudo nvram SystemAudioVolume=" "

  # Allow applications downloaded from anywhere (optional - may require System Settings confirmation)
  echo "Attempting to disable Gatekeeper (may require System Settings confirmation)..."
  if ! sudo spctl --master-disable 2>/dev/null; then
    echo "⚠️  Could not disable Gatekeeper automatically - you may need to disable it manually in System Settings > Privacy & Security"
  else
    echo "✅ Gatekeeper disabled successfully"
  fi

  # Disable Infrared Remote
  sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
else
  # Linux hostname setup
  sudo sed -i "s/$CURRENT_HOSTNAME/$COMPUTER_NAME/g" /etc/hostname
  sudo sed -i "s/$CURRENT_HOSTNAME/$COMPUTER_NAME/g" /etc/hosts
  sudo hostname "$COMPUTER_NAME"
fi

# Nix Installation with Flakes
progress "Installing Nix with Flakes Support"
if [[ ! $NIX_EXISTS ]]; then
  echo "Installing Nix with the Determinate Systems installer (includes flakes)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # Source the nix profile
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi

  NIX_EXISTS=$(command -v nix 2>/dev/null || echo "")

  # Ensure Nix has already been installed
  if [[ ! $NIX_EXISTS ]]; then
    echo -e "${RED}Cannot find nix in the PATH${ESC}"
    echo "This means that the nix init script has not been sourced properly"
    exit 1
  fi

  echo "✅ Nix installed successfully with flakes support"
else
  echo "✅ Nix already installed"
fi

# Platform-specific setup and configuration
progress "Platform-specific Configuration"

# sets the host for the configuration to pick up
export HOST="$COMPUTER_NAME"

# Backup original system files if they exist
if [ ! -L /etc/shells ] && [ -f /etc/shells ]; then
  sudo mv /etc/shells /etc/shells.bak
fi
if [ ! -L /etc/zprofile ] && [ -f /etc/zprofile ]; then
  sudo mv /etc/zprofile /etc/zprofile.local
fi
if [ ! -L /etc/zshrc ] && [ -f /etc/zshrc ]; then
  sudo mv /etc/zshrc /etc/zshrc.local
fi

if [ "$IS_DARWIN" == true ]; then
  echo "🍎 Setting up nix-darwin..."

  # Install nix-darwin if not present
  if [[ ! $DARWIN_REBUILD_EXISTS ]]; then
    echo "Installing nix-darwin..."
    nix run nix-darwin -- switch --flake "$NIXPKGS_BASEPATH"

    DARWIN_REBUILD_EXISTS=$(command -v darwin-rebuild 2>/dev/null || echo "")

    if [[ ! $DARWIN_REBUILD_EXISTS ]]; then
      echo -e "${RED}Cannot find darwin-rebuild in the PATH${ESC}"
      echo "nix-darwin installation may have failed"
      exit 1
    fi
  fi

  echo "Building and switching to Darwin configuration..."
  sudo darwin-rebuild switch --flake "$NIXPKGS_BASEPATH#$COMPUTER_NAME"
  echo "✅ Darwin configuration applied successfully"

elif [ "$IS_NIXOS" == true ]; then
  echo "🐧 Setting up NixOS configuration..."
  sudo nixos-rebuild switch --flake "$NIXPKGS_BASEPATH#$COMPUTER_NAME"
  echo "✅ NixOS configuration applied successfully"

else
  echo "🏠 Setting up Home Manager (standalone)..."
  # For other Linux distributions
  nix run home-manager/master -- switch --flake "$NIXPKGS_BASEPATH#simon@$COMPUTER_NAME"
  echo "✅ Home Manager configuration applied successfully"
fi

# Shell Setup
progress "Shell Configuration"
NIX_SUPPLIED_BASH="/run/current-system/sw/bin/bash"
NIX_SUPPLIED_FISH="/run/current-system/sw/bin/fish"

if [[ "$SHELL" != "/run"* && "$SHELL" != "/nix"* ]]; then
  if [[ -x "$NIX_SUPPLIED_FISH" ]]; then
    echo "Switching default shell to nix-supplied fish"
    chsh -s "$NIX_SUPPLIED_FISH"
    export SHELL="$NIX_SUPPLIED_FISH"
  elif [[ -x "$NIX_SUPPLIED_BASH" ]]; then
    echo "Switching default shell to newer nix-supplied bash"
    chsh -s "$NIX_SUPPLIED_BASH"
    export SHELL="$NIX_SUPPLIED_BASH"
  fi
fi

# 1Password SSH Agent Setup
progress "1Password SSH Agent Setup"
if [ -f "$NIXPKGS_BASEPATH/scripts/1password-ssh.sh" ]; then
  echo "Running 1Password SSH agent setup..."
  bash "$NIXPKGS_BASEPATH/scripts/1password-ssh.sh"
else
  echo "⚠️  1Password SSH setup script not found, skipping..."
  echo "You can run it manually later: ./scripts/1password-ssh.sh"
fi

# 1Password GitHub CLI Setup
progress "1Password GitHub CLI Setup"
if [ -f "$NIXPKGS_BASEPATH/scripts/1password-gh.sh" ]; then
  echo "Running 1Password GitHub CLI verification..."
  bash "$NIXPKGS_BASEPATH/scripts/1password-gh.sh" verify || true
else
  echo "⚠️  1Password GitHub CLI setup script not found, skipping..."
  echo "You can run it manually later: ./scripts/1password-gh.sh"
fi

# Re-enable IPv6 on macOS now that we have modern curl from Nix
# Tolerate missing interfaces (e.g. laptops without Ethernet) so set -e doesn't kill us
if [ "$IS_DARWIN" == true ] && [ "$IPV6_DISABLED" == "true" ]; then
  echo "Re-enabling IPv6..."
  sudo networksetup -setv6automatic Wi-Fi &>/dev/null || true
  sudo networksetup -setv6automatic Ethernet &>/dev/null || true
fi

# Final validation
progress "Final validation"
echo "Performing final configuration validation..."
validate_nix_config

echo
echo -e "${GREEN}🎉 Setup Complete!${ESC}"
echo
echo -e "${BLUE}📝 What was configured:${ESC}"
echo "  • Modern flake-based Nix configuration"
echo "  • Host-specific configuration for $COMPUTER_NAME"
if [ "$IS_DARWIN" == true ]; then
  echo "  • nix-darwin with system-level configuration"
  echo "  • macOS system preferences and security settings"
fi
echo "  • Home Manager with user-level configuration"
echo "  • 1Password SSH agent integration"
echo "  • GitHub CLI via 1Password shell plugin"
echo "  • Shell configuration (Fish/Bash)"
echo
echo -e "${YELLOW}🔄 Next Steps:${ESC}"
echo "  1. Restart your terminal to ensure all changes take effect"
echo "  2. Set up 1Password with your SSH keys and secrets"
echo "  3. Configure GitHub CLI: op plugin init gh (see README)"
echo "  4. Configure any host-specific settings in: $nixConfig"
if [ "$IS_DARWIN" == true ]; then
  echo "  5. Install Hammerspoon from https://www.hammerspoon.org/"
  echo "  6. Restart your machine for all system changes to take effect"
else
  echo "  5. Restart your machine for all system changes to take effect"
fi
echo
echo -e "${GREEN}For more information, see the README.md file.${ESC}"
