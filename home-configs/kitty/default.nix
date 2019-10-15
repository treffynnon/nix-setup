{ cfg, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    kitty
  ]);

  programs.fish.interactiveShellInit = ''
    ${pkgs.kitty}/bin/kitty + complete setup fish | source /dev/stdin
  '';

  programs.zsh.initExtra = ''
    ${pkgs.kitty}/bin/kitty + complete setup zsh | source /dev/stdin
  '';

  programs.git.extraConfig = {
    diff.tool = "kitty";
    diff.guitool = "kitty.gui";
    difftool.prompt = false;
    difftool.trustExitCode = true;
    "difftool \"kitty\"".cmd = "kitty +kitten diff $LOCAL $REMOTE";
    "difftool \"kitty.gui\"".cmd = "kitty kitty +kitten diff $LOCAL $REMOTE";
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
  xdg.configFile."kitty/diff.conf".source = ./diff.conf;
}
