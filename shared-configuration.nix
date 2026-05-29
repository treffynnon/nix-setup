{pkgs, ...}: let
  defaults = import ./lib/defaults.nix;
in {
  # Shared Nix configuration that works on all platforms
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      substituters = defaults.nix.substituters;
      trusted-public-keys = defaults.nix.trustedPublicKeys;
      experimental-features = defaults.nix.experimentalFeatures;
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
