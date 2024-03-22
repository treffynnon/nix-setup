{pkgs, ...}: {
  programs.bat = {
    enable = true;

    config = {
      theme = "paraiso_dark";
      tabs = "2";
      pager = "less -FR";
    };

    themes = {
      paraiso_dark = {
        src = ./bat/paraiso_dark.tmTheme;
      };
    };
  };
}
