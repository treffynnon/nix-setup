{pkgs, ...}: {
  home.packages = with pkgs; [
    uhubctl
  ];

  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
}
