#!/usr/bin/env bash

set -euo pipefail

ESC='\033[0m'
BLUE='\033[38;34m'
GREEN='\033[38;32m'
RED='\033[38;31m'
YELLOW='\033[38;33m'

TOTAL_STEPS=5
CURRENT_STEP=0

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo -e "${BLUE}[$CURRENT_STEP/$TOTAL_STEPS] $1${ESC}"
}

fail() {
  echo -e "${RED}❌ $*${ESC}" >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIXPKGS_BASEPATH="$(cd "$SCRIPT_DIR/.." && pwd)"

IS_DARWIN=false
IS_NIXOS=false
IS_WSL=false

if [[ "${OSTYPE:-}" == darwin* ]]; then
  IS_DARWIN=true
fi

if [[ -f /etc/nixos/configuration.nix ]]; then
  IS_NIXOS=true
fi

if [[ -r /proc/sys/kernel/osrelease ]] && grep -qi microsoft /proc/sys/kernel/osrelease; then
  IS_WSL=true
fi

source_nix_profile() {
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

ensure_nix_profile_line() {
  local profile_file="$HOME/.profile"
  local nix_line="[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'"

  if [ "$IS_DARWIN" == true ]; then
    profile_file="$HOME/.zprofile"
  elif [ -n "${ZSH_VERSION:-}" ] || [[ "${SHELL:-}" == *zsh ]]; then
    profile_file="$HOME/.zprofile"
  fi

  if [ ! -f "$profile_file" ]; then
    printf '%s\n' "$nix_line" > "$profile_file"
    return
  fi

  if ! grep -Fxq "$nix_line" "$profile_file"; then
    printf '%s\n' "$nix_line" >> "$profile_file"
  fi
}

ensure_sudo() {
  if [ "$IS_DARWIN" != true ] && [ "$IS_NIXOS" != true ]; then
    return
  fi

  if [ "$EUID" -eq 0 ]; then
    fail "Please do not run this script as root."
  fi

  if ! sudo -n true 2>/dev/null; then
    echo "Some operations must run as admin; please enter your password:"
    sudo -v
  fi

  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

target_attr() {
  if [ "$IS_DARWIN" == true ]; then
    printf 'darwinConfigurations.%s.system' "$COMPUTER_NAME"
  elif [ "$IS_NIXOS" == true ]; then
    printf 'nixosConfigurations.default.config.system.build.toplevel'
  elif [ "$IS_WSL" == true ]; then
    printf 'homeConfigurations."simon@wsl".activationPackage'
  else
    printf 'homeConfigurations."simon@linux".activationPackage'
  fi
}

validate_target() {
  local attr
  attr="$(target_attr)"
  echo "🔍 Validating Nix target: $attr"
  nix eval "$NIXPKGS_BASEPATH#$attr" >/dev/null
  echo "✅ Nix target is valid"
}

create_darwin_host_if_missing() {
  if [ "$IS_DARWIN" != true ]; then
    return
  fi

  local nix_config="$NIXPKGS_BASEPATH/hosts/$COMPUTER_NAME/configuration.nix"
  if [ -f "$nix_config" ]; then
    echo "✅ Host configuration already exists: $nix_config"
  else
    echo "Creating host-specific configuration: $nix_config"
    mkdir -p "$(dirname "$nix_config")"
    cat > "$nix_config" <<EOF
{
  networking.hostName = "$COMPUTER_NAME";
  system.stateVersion = 5;
  home-manager.users.simon.home.stateVersion = "24.05";
}
EOF
  fi

  if [ -d "$NIXPKGS_BASEPATH/.git" ] && command -v git >/dev/null 2>&1; then
    git -C "$NIXPKGS_BASEPATH" add "$nix_config" || true
  fi
}

backup_determinate_custom_conf() {
  if [ "$IS_DARWIN" != true ]; then
    return
  fi

  if [ ! -L /etc/nix/nix.custom.conf ] && [ -f /etc/nix/nix.custom.conf ]; then
    sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
  fi
}

switch_target() {
  if [ "$IS_DARWIN" == true ]; then
    backup_determinate_custom_conf
    if [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
      sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$NIXPKGS_BASEPATH#$COMPUTER_NAME"
    elif command -v darwin-rebuild >/dev/null 2>&1; then
      sudo "$(command -v darwin-rebuild)" switch --flake "$NIXPKGS_BASEPATH#$COMPUTER_NAME"
    else
      sudo -H nix run nix-darwin -- switch --flake "$NIXPKGS_BASEPATH#$COMPUTER_NAME"
    fi
  elif [ "$IS_NIXOS" == true ]; then
    sudo nixos-rebuild switch --flake "$NIXPKGS_BASEPATH#default"
  elif [ "$IS_WSL" == true ]; then
    nix run home-manager -- switch --flake "$NIXPKGS_BASEPATH#simon@wsl"
  else
    nix run home-manager -- switch --flake "$NIXPKGS_BASEPATH#simon@linux"
  fi
}

echo -e "${GREEN}🚀 Starting Nix Configuration Bootstrap${ESC}"
echo -e "Configuration path: ${BLUE}$NIXPKGS_BASEPATH${ESC}"
echo

source_nix_profile
ensure_sudo

progress "Preparing host target"
if [ "$IS_DARWIN" == true ]; then
  read -r -p "Pick a name for this machine [$(hostname)]: " COMPUTER_NAME
  if [ -z "$COMPUTER_NAME" ]; then
    COMPUTER_NAME="$(hostname)"
  fi
  create_darwin_host_if_missing
elif [ "$IS_NIXOS" == true ]; then
  COMPUTER_NAME="default"
elif [ "$IS_WSL" == true ]; then
  COMPUTER_NAME="wsl"
else
  COMPUTER_NAME="linux"
fi
echo -e "Using target ${GREEN}$COMPUTER_NAME${ESC}"

progress "Installing or sourcing Nix"
if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix with the Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  source_nix_profile
  ensure_nix_profile_line
fi
command -v nix >/dev/null 2>&1 || fail "Nix is still not available in PATH. Restart your shell and rerun setup."
echo "✅ Nix is available"

progress "Validating target"
validate_target

progress "Switching configuration"
switch_target

progress "Final validation"
export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$PATH"
validate_target

echo
echo -e "${GREEN}🎉 Bootstrap complete${ESC}"
echo "Verification commands:"
echo "  nix run .#verify-1password-ssh"
echo "  nix run .#verify-1password-gh"
echo "  nix flake check --no-build --show-trace"
echo
echo -e "${YELLOW}Restart your terminal before starting normal work.${ESC}"
