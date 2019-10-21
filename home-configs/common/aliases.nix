{ pkgs, ... }:
rec {
  envAliases = {
    icat = "${pkgs.kitty}/bin/kitty +kitten icat";
    d = "${pkgs.kitty}/bin/kitty +kitten diff";
    gd = "${pkgs.git}/bin/git difftool --no-symlinks --dir-diff";
    gs = "${pkgs.git}/bin/git status";
    pcat = "pygmentize -f terminal256 -O style=paraiso-dark -g";
  };
}
