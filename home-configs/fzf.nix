{pkgs, ...}: let
  # copied from https://github.com/nicodebo/base16-fzf/blob/6d40da6cc12265911c688b48d986dda0f9bded93/bash/base16-paraiso.config
  paraiso-base16-theme = {
    color00 = "#2f1e2e";
    color01 = "#41323f";
    color02 = "#4f424c";
    color03 = "#776e71";
    color04 = "#8d8687";
    color05 = "#a39e9b";
    color06 = "#b9b6b0";
    color07 = "#e7e9db";
    color08 = "#ef6155";
    color09 = "#f99b15";
    color0A = "#fec418";
    color0B = "#48b685";
    color0C = "#5bc4bf";
    color0D = "#06b6ef";
    color0E = "#815ba4";
    color0F = "#e96ba8";
  };
in {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    colors = with paraiso-base16-theme; {
      # base line style
      fg = "${color04}";
      bg = "${color00}";
      hl = "${color0D}";

      # current line
      "fg+" = "${color0B}";
      "bg+" = "${color01}";
      "hl+" = "${color0D}";

      spinner = "${color0C}"; # streaming input indicator
      header = "${color0D}";
      info = "${color0A}";
      pointer = "${color0C}"; # pointer to the current line
      marker = "${color0C}"; # multi-select marker
      prompt = "${color0A}";
    };

    defaultCommand = "${pkgs.fzf}/bin/fd --type f";
    fileWidgetCommand = "${pkgs.fzf}/bin/fd --type f \$dir";
  };
}
