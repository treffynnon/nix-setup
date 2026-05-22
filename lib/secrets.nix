# Secrets management using opnix (1Password integration)
# This module provides secure secret handling via 1Password CLI
{ lib, pkgs, ... }:

{
  secretRefs = {
    sshSigningKey = "op://Nix Config/GitHub Commit Signing Key/public key";
  };

  getSSHSigningKey = builtins.getEnv "NIX_SSH_SIGNING_KEY";

  environmentSecrets = {
    NIX_SSH_SIGNING_KEY = builtins.getEnv "NIX_SSH_SIGNING_KEY";
  };
}
