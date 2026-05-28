# 1Password secrets management with opnix
# This module handles all opnix-related configuration for home-manager
{...}: {
  # Configure 1Password secrets management with opnix
  # Note: new opnix API takes `secrets` as an attrset keyed by camelCase name
  # instead of a list. Key names must match /^[a-z][a-zA-Z0-9]*$/.
  programs.onepassword-secrets = {
    enable = true;
    secrets = {
      sshSigningKey = {
        path = ".ssh-signing-key";
        reference = "op://Nix Config/GitHub Commit Signing Key/public key";
      };
    };
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
