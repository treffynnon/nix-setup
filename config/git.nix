{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Simon Holywell";
    userEmail = "treffynnon@php.net";
  };

  programs.git.extraConfig = {
    "filter \"lfs\"" = {
      clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
      smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
      process = "${pkgs.git-lfs}/bin/git-lfs filter-process";
      required = true;
    };

    github = {
      user = "treffynnon";
    };

    "protocol \"keybase\"" = {
      allow = "always";
    };
  };

  home.packages = with pkgs; [
    git-crypt
    git-lfs
  ];
}
