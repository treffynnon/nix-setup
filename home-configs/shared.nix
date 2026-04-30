# Shared home-manager configuration
# This eliminates the massive duplication of home-manager imports across
# darwin-configuration.nix, nixos-configuration.nix, and home-manager-configuration.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  # Import our centralised configuration directly to avoid circular dependencies
  defaults = import ../lib/defaults.nix;
in {
  # Core home-manager module imports
  imports = [
    ./git.nix
    ./fish.nix
    ./starship.nix
    ./neovim.nix
    ./kitty.nix
    ./bat.nix
    ./fzf.nix
    ./direnv.nix
    ./vscode.nix
    ./bash.nix
    ./environment.nix
    ./helix.nix
    ./irssi.nix
    ./pgcli.nix
    ./vifm.nix
    ./webstorm.nix
    ./opnix.nix
    ./1password-ssh.nix
    ./claude-code.nix
    ./jujutsu.nix
    # Platform-specific modules will be imported by individual configs
    # Uncomment these if needed:
    # ./firefox.nix
    # ./httpie.nix
  ];

  # Core home packages that work everywhere
  home.packages = with pkgs; [
    # Tools that work everywhere
    uhubctl
    fzf
    bat
    direnv
  ];

  # Nix configuration for home-manager
  nix = {
    # Enable experimental flakes support
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # Note: nixpkgs.config and nixpkgs.overlays are intentionally NOT set here
  # When using home-manager.useGlobalPkgs = true, the home-manager configuration
  # inherits nixpkgs configuration from the system configuration automatically
}
