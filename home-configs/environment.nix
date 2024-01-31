{ pkgs, ... }:

{
  home.sessionVariables = {
    DEVELOPER = "sholywell";
    VISUAL = "${pkgs.neovim-unwrapped}/bin/nvim";
    EDITOR = "${pkgs.neovim-unwrapped}/bin/nvim";
  };
}
