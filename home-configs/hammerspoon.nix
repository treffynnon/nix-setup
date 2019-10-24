{ pkgs, ... }:

{
  home.packages = [ pkgs.Hammerspoon ];

  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
}
