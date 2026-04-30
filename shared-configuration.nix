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
        "hnix.cachix.org-1:8MflOlogfd6Y94rD0cjHsmfK0qIF8F5dPz4TSY7qSdU="
        "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE"
      ];
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
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

  # Core system packages that work on all platforms
  environment.systemPackages = with pkgs; [
    # Core utilities
    gnupg
    pass
    curl
    wget
    dnsutils
    nmap
    inetutils

    # Secrets management
    _1password-cli

    # File and text processing
    less
    delta
    jq # JSON processor
    yq # YAML/JSON processor
    imagemagick
    ripgrep
    unzip
    zip
    gzip
    zstd

    # System tools
    fd
    file
    pv
    htop
    which
    eza

    # Git tools
    git-lfs
    git-crypt

    # Nix tools
    any-nix-shell

    # Development tools
    cmus

    # Git tools (previously under pkgs.gitAndTools, now top-level)
    gitFull
    git-fame
  ];

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
