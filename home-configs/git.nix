{pkgs, ...}: let
  sshPubKey = "~/.ssh/id_rsa.pub";
in {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        hyperlinks = true;
        hyperlinks-file-link-format = "vscode://file/{path}:{line}";

        features = "decorations interactive";

        interactive = {
          keep-plus-minus-markers = false;
        };

        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };
    userName = "Simon Holywell";
    userEmail = "simon@holywell.au";

    ignores = [
      "*.sw?"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".direnv"
    ];

    aliases = {
      wd = "diff --word-diff";
      d = "difftool --no-symlinks --dir-diff";
      bl = "git blame -w -C -C -C";
      pickaxe = "log -S";
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };

      rerere = {
        # remembers previous resolutions
        enabled = true;
      };

      column = {
        # uses columns for like branch output
        ui = "auto";
      };

      branch = {
        # sort the branch output by committerdate most recent first
        sort = "committerdate";
      };

      gpg = {
        # use the SSH key to sign commits instead of GPG
        format = "ssh";
      };

      user = {
        # use the SSH key to sign commits instead of GPG
        signingkey = sshPubKey;
      };

      commit = {
        # automatically sign all the commits
        gpgsign = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      pull = {
        rebase = true;
      };

      github = {
        user = "treffynnon";
      };

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
