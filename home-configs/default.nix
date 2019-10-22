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

    ./environment.nix

    ./nix.nix
    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fish.nix
    # ./firefox.nix
    ./fzf.nix
    ./git.nix
    ./httpie.nix
    ./kitty.nix
    ./neovim.nix
    ./starship.nix
    ./vscode.nix
  ];
}
