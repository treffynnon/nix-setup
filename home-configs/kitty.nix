{ cfg, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    kitty
  ]);

  programs.bash.initExtra = ''
    source <(${pkgs.kitty}/bin/kitty + complete setup bash)
  '';

  programs.fish.interactiveShellInit = ''
    ${pkgs.kitty}/bin/kitty + complete setup fish | source
  '';

  programs.zsh.initExtra = ''
    ${pkgs.kitty}/bin/kitty + complete setup zsh | source /dev/stdin
  '';

  programs.git.extraConfig = {
    diff.tool = "${pkgs.kitty}/bin/kitty";
    diff.guitool = "${pkgs.kitty}/bin/kitty.gui";
    difftool.prompt = false;
    difftool.trustExitCode = true;
    "difftool \"kitty\"".cmd = "${pkgs.kitty}/bin/kitty +kitten diff $LOCAL $REMOTE";
    "difftool \"kitty.gui\"".cmd = "${pkgs.kitty}/bin/kitty kitty +kitten diff $LOCAL $REMOTE";
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/diff.conf".source = ./kitty/diff.conf;
}
