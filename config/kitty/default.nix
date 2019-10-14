{ cfg, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    kitty
  ]);

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
  xdg.configFile."kitty/diff.conf".source = ./diff.conf;
}
