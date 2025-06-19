{pkgs, lib, opnix, ...}:
let
  # Import our centralised configuration directly  
  defaults = import ./lib/defaults.nix;
in {
  # Import our unified home-manager configuration
  imports = [
    opnix.homeManagerModules.default  # Required for programs.onepassword-secrets
    ./home-configs/shared.nix
  ];
  
  # Required for standalone home-manager
  home.username = defaults.user.username;
  home.homeDirectory = 
    if pkgs.stdenv.isDarwin 
    then "/Users/${defaults.user.username}"
    else "/home/${defaults.user.username}";
  
  # Note: home.stateVersion should be set in host-specific configurations
  # For standalone home-manager, set it here based on when you first installed it
  home.stateVersion = "24.05"; # Adjust based on your installation date

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
