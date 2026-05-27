# Shared home-manager configuration
# This eliminates the massive duplication of home-manager imports across
# darwin-configuration.nix, nixos-configuration.nix, and home-manager-configuration.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  defaults = import ../lib/defaults.nix;
in {
  imports = [
    ./git.nix
    ./github.nix
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
    ./pgcli.nix
    ./vifm.nix
    ./opnix.nix
    ./claude-code.nix
    ./jujutsu.nix
  ];

  nix.settings.experimental-features = defaults.nix.experimentalFeatures;

  # Note: nixpkgs.config and nixpkgs.overlays are intentionally NOT set here
  # When using home-manager.useGlobalPkgs = true, the home-manager configuration
  # inherits nixpkgs configuration from the system configuration automatically
}
