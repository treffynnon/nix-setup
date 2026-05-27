{
  # Host-specific configuration for gecko
  networking.hostName = "gecko";

  # Set the state version based on when you first installed this system
  # NEVER change this unless you understand the migration implications
  system.stateVersion = 5;  # Auto-detected

  # Home Manager state version
  home-manager.users.simon.home.stateVersion = "24.05";

  # Add any host-specific overrides here
}
