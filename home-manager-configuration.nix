{
  pkgs,
  lib,
  opnix,
  ...
}: let
  # Import our centralised configuration directly
  defaults = import ./lib/defaults.nix;
in {
  # Import our unified home-manager configuration
  imports = [
    opnix.homeManagerModules.default # Required for programs.onepassword-secrets
    ./home-configs/shared.nix
  ];

  # Required for standalone home-manager
  home = {
    inherit (defaults.user) username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${defaults.user.username}"
      else "/home/${defaults.user.username}";
    stateVersion = "24.05";
  };

  # Required for standalone home-manager: set nix package
  nix.package = pkgs.nix;

  # Nixpkgs configuration for standalone home-manager
  # This is needed because standalone home-manager doesn't inherit from system config
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    allowUnsupportedSystem = false;
  };
}
