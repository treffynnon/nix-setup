{
  pkgs,
  lib,
  config,
  ...
}: let
  # Import our centralised configuration
  helpers = import ../lib/helpers.nix {inherit lib;};
  inherit (helpers) defaults;

  sshSigningKey = "~/.ssh-signing-key";
in {
  # delta moved out of programs.git; now a top-level home-manager module
  programs.delta = {
    enable = true;
    # new home-manager requires explicit opt-in for git integration
    enableGitIntegration = true;
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

  programs.git = {
    enable = true;

    ignores = [
      "*.sw?"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".direnv"
      ".jj"
    ];

    # adopt new default; silences pre-25.05 legacy openpgp warning
    signing.format = null;

    # settings replaces extraConfig/aliases/userName/userEmail in newer home-manager
    settings = {
      # Use centralised user configuration
      user = {
        name = defaults.user.fullName;
        inherit (defaults.user) email;
        signingkey = sshSigningKey;
      };

      alias = {
        wd = "diff --word-diff";
        d = "difftool --no-symlinks --dir-diff";
        bl = "git blame -w -C -C -C";
        pickaxe = "log -S";
      };

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

      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };

      commit = {
        gpgsign = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      pull = {
        rebase = true;
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
