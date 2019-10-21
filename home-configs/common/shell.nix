{ pkgs, ... }:
rec {
  envVars = {
    DEVELOPER="sholywell";
    VISUAL="${pkgs.neovim}/bin/nvim";
    EDITOR="${pkgs.neovim}/bin/nvim";
    GIT_PS1_SHOWDIRTYSTATE = true;
  };
  envAliases = {
    ls = "ls -G";
    ll = "ls -Glkha";
    icat = "${pkgs.kitty}/bin/kitty +kitten icat";
    d = "${pkgs.kitty}/bin/kitty +kitten diff";
    gd = "${pkgs.git}/bin/git difftool --no-symlinks --dir-diff";
    gs = "${pkgs.git}/bin/git status";
    pcat = "pygmentize -f terminal256 -O style=paraiso-dark -g";
  };
}
