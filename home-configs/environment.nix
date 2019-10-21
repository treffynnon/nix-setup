{ pkgs, ... }:

{
  home.sessionVariables = {
    DEVELOPER = "sholywell";
    VISUAL = "${pkgs.neovim}/bin/nvim";
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };
}
