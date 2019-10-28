{ ... }:
{
  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://hie-nix.cachix.org"
      "https://hnix.cachix.org"
      "https://nix-linter.cachix.org"
    ];
    binaryCachePublicKeys = [
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
      "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
      "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE"
    ];

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      user = "simon";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
