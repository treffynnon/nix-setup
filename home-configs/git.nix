{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Simon Holywell";
    userEmail = "treffynnon@php.net";
    ignores = [
      "*.sw?"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
    ];

    aliases = {
      d = "difftool --no-symlinks --dir-diff";
    };

    extraConfig = {
      merge.tool = "vimdiff";
      "include".path = "~/.gitconfig";
      "filter \"lfs\"" = {
        clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
        smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
        process = "${pkgs.git-lfs}/bin/git-lfs filter-process";
        required = true;
      };

      github = {
        user = "treffynnon";
      };
    };
  };
}
