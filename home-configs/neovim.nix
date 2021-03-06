{ pkgs, ... }:

{
  programs.neovim = {
    package = pkgs.neovim-unwrapped;
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      base16-vim

      haskell-vim
      vim-fish
      vim-nix
      typescript-vim
    ];
    extraConfig = builtins.readFile ./neovim/vimrc.vim;
  };
}
