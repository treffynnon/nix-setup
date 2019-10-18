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

    ./nix.nix
    ./bash.nix
    ./direnv.nix
    ./fish.nix
    # ./firefox.nix
    ./fzf.nix
    ./git.nix
    ./kitty.nix
    ./neovim.nix
    ./starship.nix
    ./vscode.nix
  ];
}
