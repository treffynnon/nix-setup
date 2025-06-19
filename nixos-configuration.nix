{pkgs, home-manager, lib, opnix, ...}: 
let
  # Import our centralised configuration directly
  defaults = import ./lib/defaults.nix;
in {
  # Import shared configuration
  imports = [
    ./shared-configuration.nix
    home-manager.nixosModules.home-manager
  ];

  # NixOS/Linux-specific configuration using centralised defaults
  # Set reasonable default stateVersion for NixOS - should be overridden by host configs
  system.stateVersion = "24.05"; # Default fallback - set appropriate version in host configs
  
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
    # Initial password for new installs
    initialPassword = "correct horse battery staple";
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
    uhubctl  # USB hub control utility (useful on Linux too)
    # Linux-specific utilities
    whois
    pciutils
  ];

  # Linux-specific programs
  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  # Basic NixOS boot configuration (minimal example)
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # or "nodev" for UEFI
  };

  # Basic filesystem configuration (minimal example)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Home Manager configuration using shared configuration
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.${defaults.user.username} = {
      # Set default home.stateVersion - should be overridden by host configs
      home.stateVersion = "24.05"; # Default fallback - set appropriate version in host configs
      
      # Import our unified home-manager configuration
      imports = [
        opnix.homeManagerModules.default  # Required for programs.onepassword-secrets
        ./home-configs/shared.nix
      ];
    };
  };
}
