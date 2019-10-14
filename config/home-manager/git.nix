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
      diff.tool = "kitty";
      diff.guitool = "kitty.gui";
      merge.tool = "vimdiff";
      difftool.prompt = false;
      difftool.trustExitCode = true;
      "difftool \"kitty\"".cmd = "kitty +kitten diff $LOCAL $REMOTE"
      "difftool \"kitty.gui\"".cmd = "kitty kitty +kitten diff $LOCAL $REMOTE"
      "include".path = "~/.gitconfig";
    };
  };
}
