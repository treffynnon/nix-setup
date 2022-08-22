{ pkgs, ... }:

{
  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
}
