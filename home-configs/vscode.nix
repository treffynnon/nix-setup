{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'Fira Code', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "terminal.integrated.shellArgs.osx" = [
        "-i"
        "-l"
      ];
      "workbench.colorTheme" = "Paraiso_dark";
      "vim.enableNeovim" = true;
      "vim.neovimPath" = "${pkgs.neovim}/bin/nvim";
    };
    extensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
      alanz.vscode-hie-server
      justusadam.language-haskell
      vscodevim.vim
      skyapps.fish-vscode
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "EditorConfig";
        publisher = "EditorConfig";
        version = "0.14.2";
        sha256 = "19vqwhxqbxarswj3x2ghwk1b09bslmyw8aarnvjy6zz1jsigchl5";
      }
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "1.7.18";
        sha256 = "1n9xi08qd8j9vpy50lsh2r73c36y12cw7n87f15rc7fws6ws3x0v";
      }
      {
        name = "path-intellisense";
        publisher = "christian-kohler";
        version = "1.4.2";
        sha256 = "0i2b896cnlk1d23w3jgy8wdqsww2lz201iym5c1rqbjzg1g3v3r4";
      }
      {
        name = "theme-paraisodark";
        publisher = "gerane";
        version = "0.0.2";
        sha256 = "1wdl3ycixrm120x9r4s3053kajxlz3464q1qzv0i4q6hw0klbmki";
      }
    ];
  };
}
