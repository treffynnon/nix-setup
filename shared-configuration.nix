{
  pkgs,
  lib,
  config,
  ...
}: {
  # Shared Nix configuration that works on all platforms
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://hnix.cachix.org"
        "https://nix-linter.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
        "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE"
      ];
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Shared nixpkgs configuration with overlays
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = false;
    };
    overlays = let
      path = ./overlays;
    in
      with builtins;
        map (n: import (path + ("/" + n)))
        (
          filter
          (
            n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))
          )
          (attrNames (readDir path))
        );
  };

  environment.systemPackages =
    (import ./lib/cli-packages.nix pkgs)
    ++ (with pkgs; [
      gnupg
      pass
      curl
      wget
      dnsutils
      nmap
      inetutils
      delta
      imagemagick
      gzip
      zstd
      file
      pv
      htop
      which
      git-lfs
      git-crypt
      any-nix-shell
      cmus
      gitFull
      git-fame
    ]);

  # Shared fonts (works on both platforms)
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      iosevka-bin
      nerd-fonts.fira-code
      nerd-fonts.iosevka
    ];
  };

  # Timezone configuration
  time.timeZone = "Australia/Brisbane";
}
