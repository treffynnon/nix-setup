{ cfg, lib, pkgs, ... }:

let
  fishFilesInDir = dir: lib.filterAttrs (name: _: lib.hasSuffix ".fish" name)
                                     (builtins.readDir dir);
  linkIt = name: {xdg.configFile."fish/functions/${name}".source = "./functions/${name}";};
  x = lib.mapAttrs (name: _: (linkIt name)) (fishFilesInDir ./functions);
in

{
  home.packages = (with pkgs; [
    fish
  ]);

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."fish/config.fish".source = ./config.fish;
}
