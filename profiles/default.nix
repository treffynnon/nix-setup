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
        gnupg pass

        curl wget dnsutils nmap telnet

        less jq bat imagemagick

        ripgrep ncdu

        unzip zip gzip

        fd file pv htop which exa

        git-lfs git-crypt

        zstd

        nix-prefetch-scripts
      ])
      ++
      (with pkgs.gitAndTools; [
        gitFull git-fame
      ]);

    environment.shellAliases = {
      ls = "exa";
      ll = "exa -lh";
      la = "exa -lhaa";
      lt = "exa -lTh";
      lg = "exa -lh --git";
      lgt = "exa -lTh --git";
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
    };
    programs.zsh.enable = true;
    programs.fish.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    time.timeZone = "Australia/Brisbane";
    home-manager.useUserPackages = true;
  }

  (optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      whois pciutils
    ];
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
      gnutar
      gawk gnused
      findutils gnugrep
      fontconfig
    ];

    environment.shells = with pkgs; [ bashInteractive fish zsh ];
    system.defaults.finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };
    system.defaults.dock = {
      autohide = true;
      showhidden = true;
      mru-spaces = false;
      static-only = true;
    };
    system.defaults.trackpad.Clicking = true;
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;
  })
]
