{
  user = {
    username = "simon";
    fullName = "Simon Holywell";
    email = "simon@holywell.au";
  };

  system = {
    timezone = "Australia/Brisbane";
  };

  paths = {
    screenshotLocation = "~/Screenshots";
    sshSigningKey = ".ssh-signing-key";
  };

  onePassword = {
    platforms = {
      darwin = {
        sshAgentSocket = "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        opSshSign = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      linux = {
        sshAgentSocket = ".1password/agent.sock";
        opSshSign = "/opt/1Password/op-ssh-sign";
      };
      wsl = {
        sshAgentSocket = ".ssh/agent.sock";
        opSshSign = "/mnt/c/Program Files/1Password/op-ssh-sign.exe";
      };
    };
  };

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
    experimentalFeatures = ["nix-command" "flakes"];
  };
}
