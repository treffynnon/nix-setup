{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge optionalAttrs;
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate {system = currentSystem;}) isLinux isDarwin;

  homeManager = import ../home-configs;
  username = "simon";
in
  mkMerge [
    {
      home-manager.users."${username}" = homeManager;
      users.users."${username}".home = mkIf isDarwin "/Users/${username}";
      fonts = {
        fontDir.enable = true;
        fonts = with pkgs; [
          fira-code
          fira-code-symbols
          # mplus-outline-fonts
          iosevka-bin
          nerdfonts
        ];
      };
      environment.systemPackages = with pkgs; [
        any-nix-shell
        cmus
        lorri
      ];
    }

    (
      optionalAttrs isLinux {
        users.defaultUserShell = pkgs.fish;

        home-manager.users."${username}" = homeManager;

        users.users."${username}" = {
          isNormalUser = true;
          uid = 1000;
          linger = true;

          home = "/home/${username}";

          # should really choose something hashed, but XKCD-936 amuses me
          initialPassword = "correct horse battery staple";

          extraGroups = [
            "adbusers"
            "audio"
            "docker"
            "networkmanager"
            "render"
            "scanner"
            "lp" # SANE
            "vboxusers"
            "video"
            "wheel"
            "wireshark"
          ];
        };
      }
    )
  ]
