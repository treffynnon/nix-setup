# 1Password secrets management with opnix
# This module handles all opnix-related configuration for home-manager
{pkgs, lib, config, ...}:

{
  # Configure 1Password secrets management with opnix
  programs.onepassword-secrets = {
    enable = true;
    secrets = [
      {
        # SSH signing key for git commits
        path = ".ssh-signing-key";
        reference = "op://Nix Config/GitHub Commit Signing Key/public key";
      }
      {
        # GitHub personal access token
        path = ".github-token";
        reference = "op://Nix Config/GitHub-PAT/password";
      }
    ];
  };

  # System-level requirements for opnix
  # Note: The following are handled automatically by lib/opnix-system.nix in Darwin:
  # - onepassword-secrets group creation
  # - opnix token permissions setup
  #
  # For standalone home-manager or other platforms, you may need to manually:
  # 1. Create onepassword-secrets group and add your user
  # 2. Set permissions on /etc/opnix-token (640, group onepassword-secrets)
}
