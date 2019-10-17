{ lib, pkgs, config, ... }:

let
  inherit (lib) flatten optional optionalAttrs mkIf mkMerge;
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;
in

{
  imports = flatten [
    ./simon.nix
  ];
} //

mkMerge [
  {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowBroken = false;
        allowUnsupportedSystem = false;
      };

      overlays =
        let path = ../overlays; in with builtins;
        map (n: import (path + ("/" + n)))
            (filter (n: match ".*\\.nix" n != null ||
                        pathExists (path + ("/" + n + "/default.nix")))
                    (attrNames (readDir path)));
    };

    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    environment.systemPackages =
      (with pkgs; [
        curl wget dnsutils nmap telnet gnugrep

        jq bat imagemagick

        unzip zip gzip

        file gnupg pv htop which

        git-lfs git-crypt

        nix-prefetch-scripts
      ])
      ++
      (with pkgs.gitAndTools; [
        gitFull git-fame
      ]);

    programs.bash = {
      enable = true;
      enableCompletion = true;
    };
    programs.zsh.enable = true;
    programs.fish.enable = true;
  }

  (optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      whois pciutils
    ];

    time.timeZone = "Australia/Brisbane";
    i18n = {
      consoleFont = "Lat2-Terminus16";
      defaultLocale = "en_AU.UTF-8";
      consoleUseXkbConfig = true;
    };
    services.xserver = {
      layout = "us";
      xkbOptions = "caps:escape";
    };

    system.stateVersion = "19.09";
  })

  (mkIf isDarwin {
    environment.systemPackages = with pkgs; [
      coreutils
    ];

    environment.shells = with pkgs; [ bashInteractive fish zsh ];

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  })
]
