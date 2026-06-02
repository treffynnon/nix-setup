{
  config,
  lib,
  pkgs,
  ...
}: let
  defaults = import ../lib/defaults.nix;
  inherit (config._1password) platform;
  platformCfg = defaults.onePassword.platforms.${platform};
  agentSocket = "~/${platformCfg.sshAgentSocket}";
in {
  options._1password.platform = lib.mkOption {
    type = lib.types.enum ["darwin" "linux" "wsl"];
    default =
      if pkgs.stdenv.isDarwin
      then "darwin"
      else "linux";
    description = "Host environment for 1Password SSH agent and signing paths.";
  };

  config = {
    home = {
      sessionVariables = {
        SSH_AUTH_SOCK = "${config.home.homeDirectory}/${platformCfg.sshAgentSocket}";
      };

      file = {
        ".ssh/config" = {
          force = true;
          text = ''
            Include ~/.ssh/config.d/*
          '';
        };

        ".ssh/config.d/10-1password-agent" = {
          text = ''
            Host *
              IdentityAgent "${agentSocket}"
          '';
        };

        ".ssh/config.d/.keep" = {
          text = "";
        };

        ".config/1password/ssh/agent.toml" = {
          text = ''
            [[ssh-keys]]
            vault = "Private"

            [[ssh-keys]]
            vault = "Employee"

            [[ssh-keys]]
            vault = "Nix Config"
          '';

          target = ".config/1password/ssh/agent.toml";
        };

        ".config/1password/ssh/.keep" = {
          text = "";
        };
      };
    };
  };
}
