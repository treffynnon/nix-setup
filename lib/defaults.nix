# Centralised configuration constants and defaults
# This is the single source of truth for all user data, versions, and common settings
{
  # User configuration - centralised for consistency
  user = {
    username = "simon";
    fullName = "Simon Holywell";
    email = "simon@holywell.au";
    sshKey = "~/.ssh/id_rsa.pub";
    # SSH signing key moved to secrets management - set NIX_SSH_SIGNING_KEY environment variable
    signingSshKey = null; # Placeholder - actual key should come from environment
    # Platform-specific home directories are computed automatically
  };

  # Version management - DEPRECATED: stateVersions moved to per-host configurations
  # stateVersion should match when you first installed each system and should NOT be centralised
  # Do NOT update stateVersions unless you understand the migration implications
  # See: https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  versions = {
    # DEPRECATED: These values have been moved to individual host configurations
    # Each host should specify its own stateVersion based on installation date
    #
    # To migrate: Add stateVersion to each host's configuration.nix:
    # - For nix-darwin: system.stateVersion = <version>;
    # - For NixOS: system.stateVersion = "<version>";
    # - For home-manager: home.stateVersion = "<version>";
    #
    # Historical reference values (remove after migration):
    # homeManagerStateVersion = "24.05";
    # darwinStateVersion = 5;
    # nixosStateVersion = "24.05";
  };

  # System configuration
  system = {
    timezone = "Australia/Brisbane";
  };

  # Common paths and settings
  paths = {
    screenshotLocation = "~/Screenshots";
  };

  # Nix configuration constants
  nix = {
    substituters = [
      "https://cache.nixos.org/"
      "https://hnix.cachix.org"
      "https://nix-linter.cachix.org"
    ];
    trustedPublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
      "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE"
    ];
    gcOptions = "--delete-older-than 7d";
  };
}
