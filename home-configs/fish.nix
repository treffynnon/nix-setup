{ lib, ... }:

let
  fishFzfKeybindings = (builtins.fetchGit {
    url = https://github.com/jethrokuan/fzf.git;
    rev = "ac01d96fc6344ebeb48c03f2c9c0be5bf3b20f1c";
    ref = "master";
  });
  basePath = /. + ("/" + ((builtins.unsafeDiscardStringContext fishFzfKeybindings) + "/functions"));
  fzfFunctions = with builtins;
    lib.concatMapStringsSep
      "\n"
      (x: readFile basePath + ("/" + x))
      (filter
        (x: match ".*\\.fish" != null)
        (attrNames (readDir basePath)));
in
{
  programs.fish = {
    enable = true;
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."fish/config.fish".source = ./fish/config.fish;
  xdg.configFile."fish/functions" = {
    source = ./fish/functions;
    recursive = true;
  };

  xdg.configFile."fish/functions/___fzf.fish".text = fzfFunctions;
}
