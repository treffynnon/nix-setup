{ lib, pkgs, ... }:

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
    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages =
      (with pkgs; [
        curl wget dnsutils nmap telnet

        unzip zip gzip

        file gnupg pv htop which

        git-lfs git-crypt

        nix-prefetch-scripts
      ])
      ++
      (with pkgs.gitAndTools; [
        gitFull git-fame
      ]);
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

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  })
]
