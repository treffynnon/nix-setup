{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Simon Holywell";
    userEmail = "simon@holywell.com.au";
    signing = {
      key = "FD510786178EE858";
      signByDefault = true;
    };

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
      github = {
        user = "treffynnon";
      };
      color = {
        status      = "auto";
        diff        = "auto";
        branch      = "auto";
        interactive = "auto";
        ui          = "auto";
        sh          = "auto";
      };
      "color \"branch\"" = {
        local = "green";
        remote = "yellow";
        current = "magenta bold";
      };
      "color \"sh\"" = {
        branch      = "yellow reverse";
        workdir     = "blue bold";
        dirty       = "red";
        dirty-stash = "red";
        repo-state  = "red";
      };
      "color \"status\"" = {
        untracked = "cyan";
      };
      merge.tool = "vimdiff";
      "include".path = "~/.gitconfig";
      "filter \"lfs\"" = {
        clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
        smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
        process = "${pkgs.git-lfs}/bin/git-lfs filter-process";
        required = true;
      };
    };
  };
}
