{ config, pkgs, ... }:

{
  imports = [
    ../config/fzf.nix
  ]
  environment.systemPackages = with pkgs; [
    any-nix-shell

    bat jq imagemagick
  ];
}
