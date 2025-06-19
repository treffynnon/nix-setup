{pkgs, lib, config, ...}: let
  # Impo  # Ensure the directory exists
  home.file.".config/1password/ssh/.keep" = {
    text = "";
  };

  # Instructions for manual SSH configuration (to keep your hosts private):
  # Run the setup script: ./scripts/1password-ssh.sh
  # Or add this to your ~/.ssh/config file manually:
  #
  # # Use 1Password SSH agent for all hosts
  # Host *
  #   IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  #
  # Or add it only to specific hosts if you prefer:
  # Host github.com
  #   HostName github.com
  #   User git
  #   IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
}r centralised configuration
  helpers = import ../lib/helpers.nix { inherit lib; };
  defaults = helpers.defaults;
in {
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
