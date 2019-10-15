{ pkgs, ... }:

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
  imports = [
    ../channels/nur.nix
    ./fish
    ./firefox.nix
    ./fzf.nix
    ./git.nix
    ./kitty
    ./neovim.nix
  ];
}
