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
    home-manager.nixosModules.home-manager
  ];

  # NixOS/Linux-specific configuration using centralised defaults
  system.stateVersion = lib.mkDefault "24.05";

  # Linux-specific user configuration using centralised defaults
  users.users.${defaults.user.username} = {
    isNormalUser = true;
    shell = pkgs.fish;
    home = "/home/${defaults.user.username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "adbusers"
      "audio"
      "render"
      "scanner"
      "lp" # SANE
      "video"
      "wireshark"
    ];
  };

  # Linux-specific default shell
  users.defaultUserShell = pkgs.fish;

  # Linux-specific internationalization
  i18n = {
    defaultLocale = "en_AU.UTF-8";
  };

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Linux-specific X server configuration
  services.xserver = {
    xkb = {
      layout = "us";
      options = "caps:escape";
    };
  };

  # Linux-specific packages
  environment.systemPackages = with pkgs; [
    uhubctl # USB hub control utility (useful on Linux too)
    # Linux-specific utilities
    whois
    pciutils
  ];

  # Linux-specific programs
  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  # Home Manager configuration using shared configuration
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit opnix;};
    users.${defaults.user.username} = {
      home.stateVersion = lib.mkDefault "24.05";

      # Import our unified home-manager configuration
      imports = [
        ./home-configs/linux.nix
      ];
    };
  };
}
