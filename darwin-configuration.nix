{
  pkgs,
  home-manager,
  lib,
  opnix,
  ...
}: let
  # Import our centralised configuration directly
  defaults = import ./lib/defaults.nix;
in {
  # Import shared configuration
  imports = [
    ./shared-configuration.nix
    ./lib/opnix-system.nix # System-level opnix configuration
    home-manager.darwinModules.home-manager
  ];

  # Determinate Nix owns Nix daemon/configuration on macOS. The Determinate
  # module disables nix-darwin's built-in Nix management for us.
  determinateNix = {
    enable = true;
    customSettings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = defaults.nix.substituters;
      trusted-public-keys = defaults.nix.trustedPublicKeys;
    };
  };
  nix.gc.automatic = lib.mkForce false;

  # Host configs can override this if they were first installed with an older
  # nix-darwin state version.
  system.stateVersion = lib.mkDefault 5;

  # Set primary user for system defaults using centralised config
  system.primaryUser = defaults.user.username;

  # Note: ids.gids.nixbld is now set in individual host configurations
  # See hosts/*/darwin.nix for per-host GID overrides

  # macOS system defaults
  system = {
    keyboard = {
      # Whether to enable keyboard mappings.
      enableKeyMapping = true;
      # Whether to remap the Caps Lock key to Escape.
      remapCapsLockToEscape = true;
    };

    defaults = {
      # Finder settings
      finder = {
        # Whether to always show file extensions.
        AppleShowAllExtensions = true;
        # Whether to allow quitting of the Finder.
        QuitMenuItem = true;
        # Whether to show warnings when change the file extension of files.
        FXEnableExtensionChangeWarning = false;
        # Whether to show the full POSIX filepath in the window title.
        _FXShowPosixPathInTitle = true;
      };

      # Dock settings
      dock = {
        # Whether to automatically hide and show the dock.
        autohide = true;
        # Whether to hide Dashboard as a Space.
        dashboard-in-overlay = true;
        # Whether to make icons of hidden applications translucent.
        showhidden = true;
        # Whether to automatically rearrange spaces based on most recent use.
        mru-spaces = false;
        # Show only open applications in the Dock.
        static-only = true;
        # Size of the icons in the dock.
        tilesize = 32;
      };

      # Trackpad settings
      trackpad.Clicking = true;

      # LaunchServices settings
      LaunchServices.LSQuarantine = false;

      # Global domain settings
      NSGlobalDomain = {
        # Sets the level of font smoothing (sub-pixel font rendering).
        AppleFontSmoothing = 1;
        # When to show the scrollbars.
        AppleShowScrollBars = "Automatic";
        # Whether to enable automatic capitalization.
        NSAutomaticCapitalizationEnabled = false;
        # Whether to enable smart dash substitution.
        NSAutomaticDashSubstitutionEnabled = false;
        # Whether to enable smart period substitution.
        NSAutomaticPeriodSubstitutionEnabled = false;
        # Whether to enable smart quote substitution.
        NSAutomaticQuoteSubstitutionEnabled = false;
        # Whether to enable automatic spelling correction.
        NSAutomaticSpellingCorrectionEnabled = false;
        # Whether to save new documents to iCloud by default.
        NSDocumentSaveNewDocumentsToCloud = false;
        # Whether to use expanded save panel by default.
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        # Sets the size of the finder sidebar icons: 1 (small), 2 (medium) or 3 (large).
        NSTableViewDefaultSizeMode = 1;

        # Configures the trackpad tracking speed (0 to 3).
        "com.apple.trackpad.scaling" = 2.999;

        # Configures the keyboard control behaviour. Mode 3 enables full keyboard control.
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;

        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";

        "com.apple.sound.beep.volume" = 0.000;
        "com.apple.sound.beep.feedback" = 0;
      };

      # Spaces settings
      spaces.spans-displays = false; # Set Apple spaces to span multiple displays

      # Screen saver settings
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 5; # Require password 5 seconds after sleep begins
      };

      # Login window settings
      loginwindow = {
        autoLoginUser = "";
        SHOWFULLNAME = true;
        GuestEnabled = false;
      };

      # Screenshot settings
      screencapture.location = defaults.paths.screenshotLocation;
    };
  };

  # Darwin-specific user configuration using centralised defaults
  users.users.${defaults.user.username} = {
    shell = pkgs.fish;
    home = "/Users/${defaults.user.username}";
  };

  # Darwin-specific shell configuration
  # Application firewall (replaces system.defaults.alf.* removed in nix-darwin)
  networking.applicationFirewall = {
    enable = true;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };

  environment.shells = with pkgs; [bashInteractive fish zsh];

  # macOS-specific system packages
  environment.systemPackages = with pkgs; [
    # macOS-specific utilities
    coreutils
    gnutar
    gawk
    gnused
    findutils
    gnugrep
    fontconfig
    fish # Fish is managed differently on Linux
  ];

  # macOS-specific programs
  programs = {
    bash = {
      enable = true;
      completion.enable = true;
    };
    fish.enable = true;
    zsh.enable = true;
  };

  # Homebrew configuration managed by nix-darwin
  homebrew = {
    enable = true;
    # Configure Homebrew behaviour
    onActivation = {
      autoUpdate = false; # Don't auto-update during nix-darwin activation
      upgrade = false; # Don't auto-upgrade packages during activation
      cleanup = "zap"; # Remove unlisted formulae and casks
    };

    # Homebrew formulae (command-line tools)
    # Minimal list - most packages moved to Nix for better reproducibility
    brews = [
      # Only keeping packages that work significantly better via Homebrew
      # or are not available/problematic in Nix on macOS
    ];

    # Homebrew casks (GUI applications)
    # These are typically not available in Nix or work better as native macOS apps
    casks = [
      "betterdisplay" # macOS display management utility
    ];
  };

  # Home Manager configuration using shared configuration
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit opnix;};
    backupFileExtension = ".hm-bak";
    users.${defaults.user.username} = {
      # Import our unified home-manager configuration
      imports = [
        ./home-configs/darwin.nix
      ];

      home = {
        username = defaults.user.username;
        homeDirectory = "/Users/${defaults.user.username}";
        stateVersion = lib.mkDefault "24.05";
      };

      nix.package = pkgs.nix;
    };
  };
}
