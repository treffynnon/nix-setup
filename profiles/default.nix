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
} // mkMerge [
  {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowBroken = false;
        allowUnsupportedSystem = false;
      };

      overlays =
        let
          path = ../overlays;
        in
          with builtins;
          map (n: import (path + ("/" + n)))
            (
              filter (
                n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))
              )
                (attrNames (readDir path))
            );
    };

    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    environment.systemPackages =
      (
        with pkgs; [
          gnupg
          pass

          curl
          wget
          dnsutils
          nmap
          telnet
          privoxy

          less
          jq
          bat
          imagemagick

          ripgrep
          ncdu

          unzip
          zip
          gzip

          fd
          file
          pv
          htop
          which
          exa

          git-lfs
          git-crypt

          zstd

          nix-prefetch-scripts
        ]
      )
      ++ (
        with pkgs.gitAndTools; [
          gitFull
          git-fame
        ]
      );

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

    services.privoxy = {
      enable = true;
      listenAddress = "127.0.0.1:8118";
    };

    time.timeZone = "Australia/Brisbane";
  }

  (
    optionalAttrs isLinux {
      environment.systemPackages = with pkgs; [
        whois
        pciutils
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
    }
  )

  (
    mkIf isDarwin {
      environment.systemPackages = with pkgs; [
        coreutils
        gnutar
        gawk
        gnused
        findutils
        gnugrep
        fontconfig
      ];

      # https://github.com/LnL7/nix-darwin/blob/master/modules/system/shells.nix
      # A list of permissible login shells for user accounts.
      # No need to mention <literal>/bin/sh</literal>
      # and other shells that are available by default on
      # macOS.
      environment.shells = with pkgs; [ bashInteractive fish zsh ];

      # https://github.com/LnL7/nix-darwin/blob/master/modules/system/keyboard.nix
      system.keyboard = {
        # Whether to enable keyboard mappings.
        enableKeyMapping = true;
        # Whether to remap the Caps Lock key to Control.
        remapCapsLockToControl = true;
      };

      # https://github.com/LnL7/nix-darwin/tree/master/modules/system/defaults
      system.defaults = {
        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/finder.nix
        finder = {
          # Whether to always show file extensions.  The default is false.
          AppleShowAllExtensions = true;
          # Whether to allow quitting of the Finder.  The default is false.
          QuitMenuItem = true;
          # Whether to show warnings when change the file extension of files.  The default is true.
          FXEnableExtensionChangeWarning = false;
          # Whether to show the full POSIX filepath in the window title.  The default is false.
          _FXShowPosixPathInTitle = true;
        };

        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/dock.nix
        dock = {
          # Whether to automatically hide and show the dock.  The default is false.
          autohide = true;
          # Whether to hide Dashboard as a Space. The default is false;
          dashboard-in-overlay = true;
          # Whether to make icons of hidden applications tranclucent.  The default is false.
          showhidden = true;
          # Whether to automatically rearrange spaces based on most recent use.  The default is true.
          mru-spaces = false;
          # Show only open applications in the Dock. The default is false.
          static-only = true;
          # Size of the icons in the dock.  The default is 64.
          tilesize = 32;
        };

        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/trackpad.nix
        # Whether to enable trackpad tap to click.  The default is false.
        trackpad.Clicking = true;

        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/LaunchServices.nix
        # Whether to enable quarantine for downloaded applications.  The default is true.
        LaunchServices.LSQuarantine = false;

        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/NSGlobalDomain.nix
        NSGlobalDomain = {
          # Sets the level of font smoothing (sub-pixel font rendering).
          AppleFontSmoothing = 1;
          # When to show the scrollbars. Options are 'WhenScrolling', 'Automatic' and 'Always'.
          AppleShowScrollBars = "Automatic";
          # Whether to enable automatic capitalization.  The default is true.
          NSAutomaticCapitalizationEnabled = false;
          # Whether to enable smart dash substitution.  The default is true.
          NSAutomaticDashSubstitutionEnabled = false;
          # Whether to enable smart period substitution.  The default is true.
          NSAutomaticPeriodSubstitutionEnabled = false;
          # Whether to enable smart quote substitution.  The default is true.
          NSAutomaticQuoteSubstitutionEnabled = false;
          # Whether to enable automatic spelling correction.  The default is true.
          NSAutomaticSpellingCorrectionEnabled = false;
          # Whether to save new documents to iCloud by default.  The default is true.
          NSDocumentSaveNewDocumentsToCloud = false;
          # Whether to use expanded save panel by default.  The default is false.
          NSNavPanelExpandedStateForSaveMode = true;
          # Whether to use expanded save panel by default.  The default is false.
          NSNavPanelExpandedStateForSaveMode2 = true;
          # Sets the size of the finder sidebar icons: 1 (small), 2 (medium) or 3 (large). The default is 3.
          NSTableViewDefaultSizeMode = 1;

          # Configures the trackpad tracking speed (0 to 3).  The default is "1".
          "com.apple.trackpad.scaling" = "2.9999999";

          # Configures the keyboard control behavior.  Mode 3 enables full keyboard control.
          AppleKeyboardUIMode = 3;
          ApplePressAndHoldEnabled = false;
          InitialKeyRepeat = 10;
          KeyRepeat = 1;

          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = 1;
          AppleTemperatureUnit = "Celsius";

          "com.apple.sound.beep.volume" = "0.000";
          "com.apple.sound.beep.feedback" = 0;
        };
        alf = {
          globalstate = 1;
          allowsignedenabled = 1;
          allowdownloadsignedenabled = 1;
          loggingenabled = 1;
          stealthenabled = 1;
        };
        loginwindow = {
          autoLoginUser = "";
          SHOWFULLNAME = true;
          GuestEnabled = false;
        };

        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/screencapture.nix
        # The filesystem path to which screencaptures should be written.
        screencapture.location = "~/Screenshots";
      };

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;
    }
  )
]
