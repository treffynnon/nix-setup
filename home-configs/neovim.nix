{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      base16-vim

      haskell-vim vim-fish vim-nix typescript-vim
    ];
    extraConfig = builtins.readFile ./neovim/vimrc;
  };
}
