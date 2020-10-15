{ pkgs, ... }:
rec {
  envAliases = {
    icat = "${pkgs.kitty}/bin/kitty +kitten icat";
    d = "${pkgs.kitty}/bin/kitty +kitten diff";
    gd = "${pkgs.git}/bin/git difftool --no-symlinks --dir-diff";
    gs = "${pkgs.git}/bin/git status";
    pcat = "pygmentize -f terminal256 -O style=paraiso-dark -g";
    ls = "exa";
    ll = "exa -lh";
    la = "exa -lhaa";
    lt = "exa -lTh";
    lg = "exa -lh --git";
    lgt = "exa -lTh --git";
  };
}
