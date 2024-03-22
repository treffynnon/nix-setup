{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      font_family = "mplusNerdFontCompleteM-regular";
      font_size = 15;
      enable_audio_bell = false;
      active_border_color = "#48b685";
      bell_border_color = "#ef6155";
      macos_custom_beam_cursor = true;
      shell = "${pkgs.fish}/bin/fish --login --interactive";
    };
    theme = "Parasio Dark";
    shellIntegration = {
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };

  programs.git.extraConfig = {
    diff.tool = "kitty";
    diff.guitool = "kitty.gui";
    difftool.prompt = false;
    difftool.trustExitCode = true;
    "difftool \"kitty\"".cmd = "${pkgs.kitty}/bin/kitty +kitten diff $LOCAL $REMOTE";
    "difftool \"kitty.gui\"".cmd = "${pkgs.kitty}/bin/kitty kitty +kitten diff $LOCAL $REMOTE";
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."kitty/diff.conf".source = ./kitty/diff.conf;
}
