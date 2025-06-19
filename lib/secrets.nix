# Secrets management using opnix (1Password integration)
# This module provides secure secret handling via 1Password CLI
{ lib, pkgs, ... }:

{
  # Secret references configuration
  # These reference your actual 1Password items
  secretRefs = {
    # SSH signing key from your existing 1Password item
    # Using the public key field from "GitHub Commit Signing Key" item
    sshSigningKey = "op://Nix Config/GitHub Commit Signing Key/public key";
    
    # GitHub personal access token from 1Password
    # Uses the password field from your existing "GitHub-PAT" item  
    githubToken = "op://Nix Config/GitHub-PAT/password";
    
    # Add more secret references here as needed
    # Example: "op://vault/item/field"
  };

  # Helper functions to get secrets (for use in other modules)
  # These fall back to environment variables when opnix is not available
  getSSHSigningKey = builtins.getEnv "NIX_SSH_SIGNING_KEY";
  getGithubToken = builtins.getEnv "NIX_GITHUB_TOKEN";
  
  # Environment variables for accessing secrets
  # When opnix is available, it will override these with 1Password values
  environmentSecrets = {
    NIX_SSH_SIGNING_KEY = builtins.getEnv "NIX_SSH_SIGNING_KEY";
    NIX_GITHUB_TOKEN = builtins.getEnv "NIX_GITHUB_TOKEN";
  };
}
