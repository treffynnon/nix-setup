{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Simon Holywell";
    userEmail = "simon@holywell.com.au";
    # signing = {
    #   key = "3346447094AB9095";
    #   signByDefault = true;
    # };

    ignores = [
      "*.sw?"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".direnv"
    ];

    aliases = {
      d = "difftool --no-symlinks --dir-diff";
    };

    extraConfig = {
      github = {
        user = "treffynnon";
      };
      core = {
        # change the pager so that the changed part of the line is highlighted
        pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | ${pkgs.less}/bin/less --tabs=2 -RFX";
      };
      # this is for diffs shown during times like `git add -p`
      interactive.diffFilter = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight";
      add.interactive.useBuiltin = false; # required for git 2.37.0

      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        interactive = "auto";
        ui = "auto";
        sh = "auto";
      };
      "color \"branch\"" = {
        local = "green";
        remote = "yellow";
        current = "magenta bold";
      };
      # highlights word changes within a line
      "color \"diff-highlight\"" = {
        oldNormal = "red";
        oldHighlight = "red bold reverse";
        newNormal = "green";
        newHighlight = "green bold reverse";
      };
      "color \"sh\"" = {
        branch = "yellow reverse";
        workdir = "blue bold";
        dirty = "red";
        dirty-stash = "red";
        repo-state = "red";
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
