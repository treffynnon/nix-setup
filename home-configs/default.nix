{lib, ...}: let
  inherit (lib) optionals;
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate {system = currentSystem;}) isLinux isDarwin;
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = false;
    };

    overlays = let
      path = ../overlays;
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
  imports =
    [
      ../channels/nur.nix

      ./environment.nix

      ./nix.nix
      ./bash.nix
      ./bat.nix
      ./direnv.nix
      ./fish.nix
      # ./firefox.nix
      ./fzf.nix
      ./git.nix
      ./helix.nix
      # ./httpie.nix
      ./irssi.nix
      ./kitty.nix
      ./neovim.nix
      ./pgcli.nix
      ./starship.nix
      ./vifm.nix
      ./vscode.nix
      ./webstorm.nix
    ]
    ++ optionals isDarwin [
      ./hammerspoon.nix
    ];

  home.stateVersion = "22.11";
}
