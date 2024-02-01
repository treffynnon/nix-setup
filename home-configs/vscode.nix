{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    userSettings = {
      "telemetry.enableTelemetry" = false;
      "telemetry.enableCrashReporter" = false;
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'Fira Code', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "editor.lineNumbers" = "relative";
      "terminal.integrated.shell.osx" = "${pkgs.fish}/bin/fish";
      "terminal.integrated.shellArgs.osx" = [
        "-i"
        "-l"
      ];
      "workbench.colorTheme" = "Paraíso (dark)";

      "[typescript][json][javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      "editor.formatOnPaste" = false;
      "editor.formatOnType" = false;
      "editor.formatOnSave" = true;
      "editor.formatOnSaveMode" = "file";

      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };

      "vscode-neovim.neovimExecutablePaths.darwin" = "${pkgs.neovim-unwrapped}/bin/nvim";
      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim-unwrapped}/bin/nvim";

      "projectManager.git.baseFolders" = [
        "~/projects"
      ];

      # Paraiso dark from https://glitchbone.github.io/vscode-base16-term/#/paraiso
      # "workbench.colorCustomizations" = {
      #   "terminal.background" = "#2F1E2E";
      #   "terminal.foreground" = "#A39E9B";
      #   "terminal.ansiBlack" = "#2F1E2E";
      #   "terminal.ansiBlue" = "#06B6EF";
      #   "terminal.ansiBrightBlack" = "#776E71";
      #   "terminal.ansiBrightBlue" = "#06B6EF";
      #   "terminal.ansiBrightCyan" = "#5BC4BF";
      #   "terminal.ansiBrightGreen" = "#48B685";
      #   "terminal.ansiBrightMagenta" = "#815BA4";
      #   "terminal.ansiBrightRed" = "#EF6155";
      #   "terminal.ansiBrightWhite" = "#E7E9DB";
      #   "terminal.ansiBrightYellow" = "#FEC418";
      #   "terminal.ansiCyan" = "#5BC4BF";
      #   "terminal.ansiGreen" = "#48B685";
      #   "terminal.ansiMagenta" = "#815BA4";
      #   "terminal.ansiRed" = "#EF6155";
      #   "terminal.ansiWhite" = "#A39E9B";
      #   "terminal.ansiYellow" = "#FEC418";
      #   "terminalCursor.background" = "#A39E9B";
      #   "terminalCursor.foreground" = "#A39E9B";
      # };
      "vsicons.dontShowNewVersionMessage" = true;
    };
    # if you install vscode extensions then it locks the dir to only allow
    # nix sourced extensions to be installed and you cannot install from the
    # internal vscode marketplace. This may be fixed in the future though:
    # https://github.com/microsoft/vscode/issues/148945
    #
    # extensions = with pkgs.vscode-extensions; [
    #   bbenoist.Nix
    #   alanz.vscode-hie-server
    #   justusadam.language-haskell
    #   vscodevim.vim
    #   skyapps.fish-vscode
    # ]
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name = "EditorConfig";
    #     publisher = "EditorConfig";
    #     version = "0.14.2";
    #     sha256 = "19vqwhxqbxarswj3x2ghwk1b09bslmyw8aarnvjy6zz1jsigchl5";
    #   }
    #   {
    #     name = "code-spell-checker";
    #     publisher = "streetsidesoftware";
    #     version = "1.7.18";
    #     sha256 = "1n9xi08qd8j9vpy50lsh2r73c36y12cw7n87f15rc7fws6ws3x0v";
    #   }
    #   {
    #     name = "path-intellisense";
    #     publisher = "christian-kohler";
    #     version = "1.4.2";
    #     sha256 = "0i2b896cnlk1d23w3jgy8wdqsww2lz201iym5c1rqbjzg1g3v3r4";
    #   }
    #   {
    #     name = "theme-paraisodark";
    #     publisher = "gerane";
    #     version = "0.0.2";
    #     sha256 = "1wdl3ycixrm120x9r4s3053kajxlz3464q1qzv0i4q6hw0klbmki";
    #   }
    # ];
  };
}
