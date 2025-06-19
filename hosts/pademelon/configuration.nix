# Host-specific configuration for pademelon
# This file contains settings specific to this host, including stateVersion
{
  # Host identification
  networking.hostName = "pademelon";

  # stateVersion for this specific host
  # IMPORTANT: This should match when you first installed each system on THIS HOST
  # Do NOT update these unless you understand the migration implications
  # See: https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

  # Set to the nix-darwin version when you first set up nix-darwin on pademelon
  # Based on current date (June 2025), using current stable version
  system.stateVersion = 5;

  # Set to the home-manager version when you first set up home-manager on pademelon
  # Based on current date (June 2025), using current stable version
  home-manager.users.simon.home.stateVersion = "24.05";
  
  # Host-specific overrides
  # Fix GID mismatch for nixbld group (specific to pademelon)
  ids.gids.nixbld = 30000;

  # Host-specific overrides can go here
  # Example: different packages, services, or settings for this specific machine
}
