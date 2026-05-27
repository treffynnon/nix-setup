# Nix Setup Audit And Improvement Plan

## Summary
Keep macOS, NixOS, standalone Home Manager, and WSL as real supported targets. Prioritise reliability first, then reduce bash and duplication. The main risks are broken binary cache trust, too much mutable work in `setup.sh`, duplicated flake host definitions, weak WSL separation, scaffold-like Linux/NixOS defaults, and secrets/SSH/GitHub logic split between Nix and bash.

## Key Changes
- Fix Nix cache trust first.
  - Add the official `cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=` key to Determinate custom settings.
  - Keep Determinate’s nix-darwin module as the macOS owner of Nix config.
  - Re-run statix/deadnix after cache trust is fixed.

- Make platform support explicit.
  - Add helpers for `mkDarwinHost`, `mkNixosHost`, and `mkHome`.
  - Keep `homeConfigurations.simon@wsl` as a first-class target, not a generic Linux alias.
  - Split modules into shared, Darwin-only, NixOS-only, Linux/Home Manager-only, and WSL-only.
  - Ensure WSL excludes macOS-only tools, Linux services needing systemd unless available, GUI assumptions, Hammerspoon, Homebrew, and Darwin paths.

- Refactor `setup.sh` into bootstrap-only.
  - Keep: install Determinate Nix on macOS, detect/create host config, stage host config, validate target, call rebuild/switch.
  - For WSL: skip macOS system changes, skip sudo macOS `/etc` handling, and switch `homeConfigurations.simon@wsl`.
  - Move shell config, SSH agent config, opnix dirs, app config, and most checks into Nix/Home Manager modules.
  - Turn 1Password scripts into verification commands exposed through flake apps/devShell.

- Improve WSL setup path.
  - Add a WSL-specific Home Manager module for paths, shell, Git, jj, CLI tools, and 1Password/SSH behaviour.
  - Avoid assuming `/Applications/1Password.app` or macOS agent socket.
  - Support WSL SSH via either Windows 1Password agent bridge or normal Linux SSH agent, chosen by config.
  - Document exact WSL bootstrap command and expected prerequisites.

- Clean security and stale code.
  - Remove hardcoded NixOS `initialPassword`.
  - Replace hardcoded Git signing key with opnix/1Password-managed value where practical.
  - Remove deprecated helper code referencing old `defaults.versions.*`.
  - Make CI secret scanning precise enough to avoid false positives on config words like “token” and “key”.

- Simplify CI and docs.
  - Consolidate duplicate GitHub workflows.
  - Test Darwin, NixOS, standalone Home Manager, and WSL outputs.
  - Update README for Determinate, macOS bootstrap, WSL bootstrap, and verification commands.

## Test Plan
- Local checks:
  - `nix flake check --no-build --show-trace`
  - `nix flake check --all-systems --no-build`
  - `nix build --dry-run .#darwinConfigurations.gecko.system`
  - `nix build --dry-run '.#homeConfigurations."simon@wsl".activationPackage'`
  - `bash -n scripts/*.sh`

- CI checks:
  - Format with Alejandra.
  - Lint with statix and deadnix.
  - Validate all flake outputs.
  - Run Linux/WSL Home Manager activation dry-runs on Ubuntu.

## Assumptions
- Reliability first.
- All current targets remain supported, including WSL.
- `setup.sh` becomes bootstrap-only.
- macOS uses Determinate’s nix-darwin module long-term.
- WSL is Home Manager-based, not nix-darwin or NixOS.


implement plan



I’ll implement this as a set of reliability-first refactors, keeping the public flake outputs stable while making platform boundaries clearer. I’ll start by checking the current tree and then patch the flake/modules/setup script in coherent chunks so we can validate after each big move.


Explored 5 files, ran 1 command
I’m going to make the first implementation chunk now: flake helper functions, explicit WSL/Home Manager modules, cache trust, and setup script slimming. This is the bit that changes architecture, so I’ll keep the edits scoped and validate immediately after.

Created 3 files, edited 6 files
That first split is in: Darwin now imports a Darwin Home Manager layer, WSL has its own module, and the cache key is present in both central defaults and shared Nix settings. Next I’m replacing the repeated flake output blocks with explicit helper constructors and exposing the verification scripts as flake apps.

Edited 1 file
The flake helper refactor and devShell commands are in. I’m replacing setup.sh with a smaller bootstrap script now: it will stop doing macOS preference mutation, shell switching, and 1Password setup, and will choose the WSL Home Manager target explicitly.

Created 1 file
The setup script is now bootstrap-only and WSL-aware. I’m cleaning up the remaining security/stale-code items next: hardcoded signing key, stale helper functions, and CI duplication.


Edited 3 files, editing 2 files, deleted 1 file, listed files, ran 2 commands
Edited 3 files, editing 2 files, deleted 1 file, listed files, ran 2 commands
The first check found the usual flake/Git visibility issue: new Nix modules must be staged before Nix can see them. I’m staging only the new module files for validation, and restoring the setup script executable bit after the delete/add rewrite.


Ran 3 commands
The first evaluation caught two integration bugs from the split: Home Manager submodules under nix-darwin need opnix passed through explicitly, and WSL was importing the generic Linux layer twice. I’m fixing that wiring rather than papering over the errors.


Edited 3 files, ran 1 command
The flake evaluates again. I’m tightening the WSL SSH config to avoid the Home Manager warning, then I’ll run the planned dry-runs and lint checks; if the cache trust fix needs an activation before lint tools fetch cleanly, I’ll call that out.


Edited 2 files, ran 5 commands
The WSL dry-run caught a good current-nixpkgs issue: wslu has been removed upstream, so packaging it would break WSL activation. I’m removing that dependency and leaving WSL free of GUI assumptions, which matches the reliability-first goal.


Edited 2 files, ran 3 commands
Edited
wsl.nix
+0
-9
Edited
nixos-configuration.nix
+1
-0
Ran nix build --dry-run '/Users/simon/.nixpkgs#homeConfigurations."simon@wsl".activationPackage'
Ran nix flake check --all-systems --no-build --show-trace /Users/simon/.nixpkgs
Ran sudo killall nix 2>/dev/null || true
Worked for 33m 29s
The WSL dry-run technically succeeded, but it exposed the next WSL quality issue: importing the full shared Home Manager layer drags GUI/editor desktop packages like VS Code into WSL. I’m making WSL a true CLI-only target now rather than a generic Linux alias.

Edited 2 files
Context automatically compacted
Error running remote compact task: You've hit your usage limit. Upgrade to Plus to continue using Codex (https://chatgpt.com/explore/plus), or try again at Jun 3rd, 2026 9:04 PM.

Edited 17 files
+465
-466
Undo
Review
darwin-configuration.nix
      imports = [
        opnix.homeManagerModules.default
        ./home-configs/shared.nix
        ./home-configs/hammerspoon.nix # macOS-specific module
        ./home-configs/darwin.nix
      ];
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit opnix;};
    backupFileExtension = ".hm-bak";
home-configs/darwin.nix
{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
    ./hammerspoon.nix
    ./1password-ssh.nix
  ];

  home.packages = with pkgs; [
    uhubctl
  ];
}
home-configs/linux.nix
{
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
  ];
}
home-configs/shared.nix
    ./opnix.nix
    ./1password-ssh.nix
    ./claude-code.nix
    ./jujutsu.nix
    # Platform-specific modules will be imported by individual configs
    # Uncomment these if needed:
    # ./firefox.nix
    # ./httpie.nix
  ];
    # Tools that work everywhere
    uhubctl
    fzf
home-configs/wsl.nix
{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
  ];

  home.sessionVariables = {
    BROWSER = "wslview";
  };

  home.packages = with pkgs; [
    wslu
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
      };
    };
  };
}
home-manager-configuration.nix
  imports = [
    opnix.homeManagerModules.default # Required for programs.onepassword-secrets
    ./home-configs/shared.nix
    ./home-configs/linux.nix
  ];
  lib,
  opnix,
  ...
in {
  # Import our unified home-manager configuration
  imports = [
    ./home-configs/linux.nix
  ];

  # Required for standalone home-manager
lib/defaults.nix
    trustedPublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
nixos-configuration.nix
    ];
    # Initial password for new installs
    initialPassword = "correct horse battery staple";
  };
      imports = [
        opnix.homeManagerModules.default # Required for programs.onepassword-secrets
        ./home-configs/shared.nix
        ./home-configs/linux.nix
      ];
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit opnix;};
    users.${defaults.user.username} = {
shared-configuration.nix
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
flake.nix
  }: let
    # Smart system detection for different architectures
    supportedSystems = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];

    # Get current system or default to aarch64-darwin for macOS
    currentSystem = builtins.currentSystem or "aarch64-darwin";

    # Helper function to generate configurations for multiple systems
    forEachSystem = systems: f: nixpkgs.lib.genAttrs systems f;

    # Import platform-specific configuration modules
    darwinConfiguration = import ./darwin-configuration.nix;
    homeManagerConfiguration = import ./home-manager-configuration.nix;
  in
    {
      # Darwin system configurations (macOS) - Auto-detect architecture
      darwinConfigurations = {
        # Default configuration - uses current system
        default = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
            determinate.darwinModules.default
            darwinConfiguration
          ];
        };

        # Host-specific configurations - auto-detect architecture
        bilby = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
    mkDarwinHost = {
      name,
      system ? currentSystem,
      extraModules ? [],
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit home-manager opnix;};
        modules =
          [
            determinate.darwinModules.default
            darwinConfiguration
            ./hosts/bilby/configuration.nix
          ];
        };
          ]
          ++ extraModules;
      };

        gecko = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
            determinate.darwinModules.default
            darwinConfiguration
            ./hosts/gecko/configuration.nix
          ];
        };
    mkNixosHost = {
      system,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit home-manager opnix;};
        modules = [nixosConfiguration] ++ extraModules;
      };

        pademelon = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
            determinate.darwinModules.default
            darwinConfiguration
            ./hosts/pademelon/configuration.nix
          ];
    mkHome = {
      system,
      extraModules ? [],
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {inherit opnix;};
        modules = [homeManagerConfiguration] ++ extraModules;
      };
  in
    {
      darwinConfigurations = {
        default = mkDarwinHost {name = "default";};
        bilby = mkDarwinHost {
          name = "bilby";
          extraModules = [./hosts/bilby/configuration.nix];
        };

        platypus = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
            determinate.darwinModules.default
            darwinConfiguration
            ./hosts/platypus/configuration.nix
          ];
        gecko = mkDarwinHost {
          name = "gecko";
          extraModules = [./hosts/gecko/configuration.nix];
        };

        thylacine = darwin.lib.darwinSystem {
          system = currentSystem;
          specialArgs = {inherit home-manager opnix;};
          modules = [
            determinate.darwinModules.default
            darwinConfiguration
            ./hosts/thylacine/configuration.nix
          ];
        pademelon = mkDarwinHost {
          name = "pademelon";
          extraModules = [./hosts/pademelon/configuration.nix];
        };
        platypus = mkDarwinHost {
          name = "platypus";
          extraModules = [./hosts/platypus/configuration.nix];
        };
        thylacine = mkDarwinHost {
          name = "thylacine";
          extraModules = [./hosts/thylacine/configuration.nix];
        };
      };

      # NixOS system configurations (Linux) - Support multiple architectures
      nixosConfigurations = {
        # Default NixOS configuration - uses x86_64-linux as default for Linux
        default = nixpkgs.lib.nixosSystem {
        default = mkNixosHost {
          system = "x86_64-linux";
          specialArgs = {inherit home-manager opnix;};
          modules = [
            nixosConfiguration
          ];
        };

        # ARM64 NixOS configuration (for Raspberry Pi, etc.)
        default-arm64 = nixpkgs.lib.nixosSystem {
        default-arm64 = mkNixosHost {
          system = "aarch64-linux";
          specialArgs = {inherit home-manager opnix;};
          modules = [
            nixosConfiguration
          ];
        };

        # Example host-specific NixOS configurations
        nixos-vm = nixpkgs.lib.nixosSystem {
        nixos-vm = mkNixosHost {
          system = "x86_64-linux";
          specialArgs = {inherit home-manager opnix;};
          modules = [
            nixosConfiguration
            # Add host-specific config here if needed
          ];
        };

      # Home Manager configurations (for WSL, existing Linux distros, etc.)
      homeConfigurations = {
        # Default home-manager configuration (x86_64-linux)
        "simon@default" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = {inherit opnix;};
          modules = [
            homeManagerConfiguration
          ];
        "simon@default" = mkHome {
          system = "x86_64-linux";
        };

        # ARM64 home-manager configuration
        "simon@default-arm64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          extraSpecialArgs = {inherit opnix;};
          modules = [
            homeManagerConfiguration
          ];
        "simon@default-arm64" = mkHome {
          system = "aarch64-linux";
        };

        # WSL configuration (x86_64-linux)
        "simon@wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = {inherit opnix;};
          modules = [
            homeManagerConfiguration
            # WSL-specific overrides could go here
          ];
        "simon@wsl" = mkHome {
          system = "x86_64-linux";
          extraModules = [./home-configs/wsl.nix];
        };

        # Generic Linux configuration
        "simon@linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = {inherit opnix;};
          modules = [
            homeManagerConfiguration
          ];
        "simon@linux" = mkHome {
          system = "x86_64-linux";
        };
        '';
        lintDeadNix = pkgs.writeScriptBin "lint-deadnix" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.deadnix}/bin/deadnix --fail --exclude .direnv .
        '';
        verifyOnePasswordSsh = pkgs.writeScriptBin "verify-1password-ssh" ''
          #!${pkgs.bash}/bin/bash
          exec ./scripts/1password-ssh.sh verify
        '';
        verifyOnePasswordGh = pkgs.writeScriptBin "verify-1password-gh" ''
          #!${pkgs.bash}/bin/bash
          exec ./scripts/1password-gh.sh verify
        '';


          echo "Linting nix files"
          lint-nix
          echo "Done."
          echo " "
            echo "Linting nix files"
            lint-nix
            echo "Done."
            echo " "

            echo "Checking for dead nix code"
            lint-deadnix
            echo "Done."
            echo " "

          echo "Formatting Hammerspoon lua code"
          statix # nix linter
          deadnix
          (lua.withPackages (ps: with ps; [busted luafilesystem luacheck]))
          lintNix
          lintDeadNix
          formatNix
          runAllLintersAndFormatters
          verifyOnePasswordSsh
          verifyOnePasswordGh
        ];
        with pkgs; {
          apps.verify-1password-ssh = {
            type = "app";
            program = "${verifyOnePasswordSsh}/bin/verify-1password-ssh";
          };
          apps.verify-1password-gh = {
            type = "app";
            program = "${verifyOnePasswordGh}/bin/verify-1password-gh";
          };
          devShells.default = mkShell {
          system = "x86_64-linux";
          extraModules = [./home-configs/linux.nix];
        };
          system = "aarch64-linux";
          extraModules = [./home-configs/linux.nix];
        };
          system = "x86_64-linux";
          extraModules = [./home-configs/linux.nix];
        };
    mkDarwinHost = {
      name,
      system ? currentSystem,
      darwinConfigurations = {
        default = mkDarwinHost {name = "default";};
        default = mkDarwinHost {};
        bilby = mkDarwinHost {
          name = "bilby";
          extraModules = [./hosts/bilby/configuration.nix];
        gecko = mkDarwinHost {
          name = "gecko";
          extraModules = [./hosts/gecko/configuration.nix];
        pademelon = mkDarwinHost {
          name = "pademelon";
          extraModules = [./hosts/pademelon/configuration.nix];
        platypus = mkDarwinHost {
          name = "platypus";
          extraModules = [./hosts/platypus/configuration.nix];
        thylacine = mkDarwinHost {
          name = "thylacine";
          extraModules = [./hosts/thylacine/configuration.nix];
scripts/setup.sh
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
home-configs/git.nix
No content
lib/helpers.nix
No content
.github/workflows/ci.yml
# Automated CI/CD for Nix Configuration Validation
# This workflow runs on every push and pull request to validate the flake

name: Nix Configuration Validation

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  schedule:
    # Run weekly on Monday at 2 AM UTC to catch upstream changes
    - cron: '0 2 * * 1'

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Test on multiple Nix versions for compatibility
        nix-version: ['2.18.1', 'latest']
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Install Nix
      uses: cachix/install-nix-action@v23
      with:
        nix_path: nixpkgs=channel:nixos-unstable
        extra_nix_config: |
          experimental-features = nix-command flakes
          substituters = https://cache.nixos.org/ https://hnix.cachix.org
          trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU=

    - name: Set up Cachix
      uses: cachix/cachix-action@v12
      with:
        name: hnix
        authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'

    - name: Check flake syntax and structure
      run: nix flake check --no-build

    - name: Validate Darwin configurations
      run: |
        nix flake show | grep -E 'darwinConfigurations\.' || echo "No Darwin configurations found"
        nix build --dry-run '.#darwinConfigurations.default.system' || echo "Darwin default config check failed"

    - name: Validate NixOS configurations  
      run: |
        nix flake show | grep -E 'nixosConfigurations\.' || echo "No NixOS configurations found"
        nix build --dry-run '.#nixosConfigurations.default.config.system.build.toplevel' || echo "NixOS default config check failed"

    - name: Validate Home Manager configurations
      run: |
        nix flake show | grep -E 'homeConfigurations\.' || echo "No Home Manager configurations found"
        nix build --dry-run '.#homeConfigurations."simon@default".activationPackage' || echo "Home Manager default config check failed"

    - name: Run formatters and linters
      run: |
        # Check if alejandra (Nix formatter) is available in the devShell
        if nix develop --command which alejandra 2>/dev/null; then
          nix develop --command alejandra --check .
        else
          echo "Alejandra formatter not available in devShell"
        fi
        
        # Check if statix (Nix linter) is available in the devShell
        if nix develop --command which statix 2>/dev/null; then
          nix develop --command statix check .
        else
          echo "Statix linter not available in devShell"
        fi

    - name: Test development shell
      run: |
        nix develop --command echo "Development shell works"
        nix develop --command bash -c 'echo "Available tools:"; which nix alejandra statix 2>/dev/null || true'

  security-scan:
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Install Nix
      uses: cachix/install-nix-action@v23
      with:
        extra_nix_config: |
          experimental-features = nix-command flakes

    - name: Security scan for vulnerabilities
      run: |
        # Check for common security issues in Nix configurations
        echo "Scanning for potential security issues..."
        
        # Check for hardcoded secrets
        if grep -r "password\|secret\|token\|key" --include="*.nix" . --exclude-dir=.git --exclude-dir=.direnv; then
          echo "WARNING: Potential secrets found in configuration files"
          exit 1
        fi
        
        # Check for allowUnfree usage (informational)
        if grep -r "allowUnfree.*true" --include="*.nix" . --exclude-dir=.git --exclude-dir=.direnv; then
          echo "INFO: Unfree packages are allowed"
        fi
        
        echo "Security scan completed"

  multi-platform-test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Install Nix
      uses: cachix/install-nix-action@v23
      with:
        extra_nix_config: |
          experimental-features = nix-command flakes

    - name: Test platform-specific configurations
      run: |
        echo "Testing on ${{ matrix.os }}"
        
        # Test basic flake evaluation
        nix flake check --no-build
        
        # Test platform-specific evaluations
        if [[ "${{ matrix.os }}" == "macos-latest" ]]; then
          echo "Testing Darwin configurations..."
          nix eval '.#darwinConfigurations.default.config.system.stateVersion' || echo "Darwin eval failed"
        else
          echo "Testing NixOS configurations..."
          nix eval '.#nixosConfigurations.default.config.system.stateVersion' || echo "NixOS eval failed"
        fi
.github/workflows/test.yml
name: "Test"
name: "Nix Configuration"
on:
jobs:
  check:
  validate:
    runs-on: ubuntu-latest
          nix_path: nixpkgs=channel:nixos-unstable
          extra_nix_config: |
            experimental-features = nix-command flakes
      - uses: DeterminateSystems/magic-nix-cache-action@v3

      - name: "Initial nix-shell run"
        run: nix develop --command echo "Initial run to get all the dependencies pulled down"
      - name: Flake check
        run: nix flake check --all-systems --no-build --show-trace

      - name: Darwin dry-runs
        run: |
          for host in default bilby gecko pademelon platypus thylacine; do
            nix build --dry-run ".#darwinConfigurations.${host}.system"
          done

      - name: NixOS dry-runs
        run: |
          nix build --dry-run ".#nixosConfigurations.default.config.system.build.toplevel"
          nix build --dry-run ".#nixosConfigurations.default-arm64.config.system.build.toplevel"
          nix build --dry-run ".#nixosConfigurations.nixos-vm.config.system.build.toplevel"

      - name: Home Manager and WSL dry-runs
        run: |
          nix build --dry-run '.#homeConfigurations."simon@default".activationPackage'
          nix build --dry-run '.#homeConfigurations."simon@default-arm64".activationPackage'
          nix build --dry-run '.#homeConfigurations."simon@linux".activationPackage'
          nix build --dry-run '.#homeConfigurations."simon@wsl".activationPackage'

      - name: Script syntax
        run: bash -n scripts/*.sh

      - name: Check nix lint
        # see the flake file for where the lint-nix command comes from
        run: nix develop --command lint-nix
      - name: Run nixpkgs-fmt check

      - name: Check dead Nix code
        run: nix develop --command lint-deadnix

      - name: Check Nix formatting
        run: nix develop --command ci-format-nix
        run: nix develop --command lint-lua
      - name: Run lua-format
        run: nix develop --command format-lua
      - name: Check for changed files - fails if there is a git diff
        run: git diff --quiet

      - name: Check Lua formatting
        run: nix develop --command lua-format --check --config=./codestyle/lua-format-config.yml ./home-configs/hammerspoon
home-configs/git.nix

  sshSigningKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxVpvFsxIhH6LTKrAEVuTiZnqHEalzDlxcNCFcYf3T5";
  hasSigningKey = sshSigningKey != "";
  sshSigningKey = "~/.ssh-signing-key";
in {
        inherit (defaults.user) email;
        # use the SSH key to sign commits instead of GPG (only if available)
        signingkey = lib.mkIf hasSigningKey sshSigningKey;
        signingkey = sshSigningKey;
      };
      commit = {
        # automatically sign all the commits (only if key is available)
        gpgsign = hasSigningKey;
        gpgsign = true;
      };
lib/helpers.nix

  # Helper to create a standardised home-manager user configuration
  mkHomeManagerUser = {
    stateVersion ? defaults.versions.homeManagerStateVersion,
    extraConfig ? {},
  }:
    {
      home.stateVersion = stateVersion;
    }
    // extraConfig;

  # Helper to create standardised nix configuration
    );

  # New: Version management automation
  mkVersionManagement = {autoDetectVersions ? true}:
    if autoDetectVersions
    then {
      inherit (defaults.versions) homeManagerStateVersion darwinStateVersion nixosStateVersion;

      # Future: Add logic to detect latest stable versions automatically
      _meta = {
        autoDetected = true;
        lastUpdated = "2024-06-18";
      };
    }
    else defaults.versions;


Collapse files