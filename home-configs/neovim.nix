{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = base16-nvim;
        type = "lua";
        config = ''
          if not vim.g.vscode then
            vim.cmd('colorscheme base16-paraiso')
          end
        '';
      }

      nvim-treesitter.withAllGrammars

      haskell-vim
      vim-fish
      vim-nix
      typescript-vim
    ];
  };
}
