# System-level opnix configuration for nix-darwin
# This module handles system-level requirements for opnix integration
{
  pkgs,
  lib,
  config,
  ...
}: let
  # Import our centralised configuration
  defaults = import ../lib/defaults.nix;
in {
  # Create onepassword-secrets group for opnix
  users.groups.onepassword-secrets = {
    members = [defaults.user.username];
  };

  # System activation script to fix opnix token permissions
  # This ensures the token file is readable by the onepassword-secrets group
  system.activationScripts.opnixTokenPermissions = {
    text = ''
      if [ -f /etc/opnix-token ]; then
        echo "Setting up opnix token permissions..."
        chgrp onepassword-secrets /etc/opnix-token 2>/dev/null || true
        chmod 640 /etc/opnix-token 2>/dev/null || true
        echo "opnix token permissions configured"
      else
        echo "Warning: /etc/opnix-token not found - opnix may not be fully configured"
      fi
    '';
  };
}
