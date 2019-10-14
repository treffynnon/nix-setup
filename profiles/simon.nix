{ pkgs, lib, ... }:

let
  inherit (lib) mkIf mkMerge optionalAttrs;
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;

  homeManager = import ../config/home-manager.nix;
in

mkMerge [
  {
    home-manager.users.simon = homeManager;
    users.users.simon.home = mkIf isDarwin "/Users/simon";
  }

  (optionalAttrs isLinux {
    users.defaultUserShell = pkgs.fish;

    home-manager.users.root = homeManager;

    users.users.simon = {
      isNormalUser = true;
      uid = 1000;
      linger = true;

      home = "/home/simon";

      # should really choose something hashed, but XKCD-936 amuses me
      initialPassword = "correct horse battery staple";

      extraGroups = [
        "adbusers"
        "audio"
        "docker"
        "networkmanager"
        "render"
        "scanner" "lp" # SANE
        "vboxusers"
        "video"
        "wheel"
        "wireshark"
      ];
    };
  })
]
