{pkgs, ...}: rec {
  envAliases = {
    icat = "${pkgs.kitty}/bin/kitty +kitten icat";
    d = "${pkgs.kitty}/bin/kitty +kitten diff";
    gd = "${pkgs.git}/bin/git difftool --no-symlinks --dir-diff";
    gs = "${pkgs.git}/bin/git status";
    pcat = "pygmentize -f terminal256 -O style=paraiso-dark -g";
    ls = "${pkgs.eza}/bin/eza";
    ll = "${pkgs.eza}/bin/eza -lh";
    la = "${pkgs.eza}/bin/eza -lhaa";
    lt = "${pkgs.eza}/bin/eza -lTh";
    lg = "${pkgs.eza}/bin/eza -lh --git";
    lgt = "${pkgs.eza}/bin/eza -lTh --git";
  };
}
