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
