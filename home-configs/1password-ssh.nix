{...}: {
  # Only manage 1Password SSH agent integration, not the full SSH config
  # This keeps your private SSH host configurations out of version control

  # Create 1Password SSH agent configuration
  home.file.".config/1password/ssh/agent.toml" = {
    text = ''
      # This is the 1Password SSH agent config file, which allows you to customize the
      # behavior of the SSH agent running on this machine.
      #
      # You can use it to:
      # * Enable keys from other vaults than the Private vault
      # * Control the order in which keys are offered to SSH servers
      #
      # More examples can be found here:
      #  https://developer.1password.com/docs/ssh/agent/config

      # Enable SSH keys from Private vault (default personal keys)
      [[ssh-keys]]
      vault = "Private"

      # Enable SSH keys from Employee vault (work-related keys)
      [[ssh-keys]]
      vault = "Employee"

      # Enable SSH keys from Nix Config vault (configuration-related keys)
      [[ssh-keys]]
      vault = "Nix Config"
    '';

    # Make it read-only to prevent accidental modification
    target = ".config/1password/ssh/agent.toml";
  };

  # Ensure the directory exists
  home.file.".config/1password/ssh/.keep" = {
    text = "";
  };
}
