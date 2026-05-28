{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "telemetry.telemetryLevel" = "off";

      "editor.wordWrap" = "on";
      "editor.fontSize" = 16;
      "editor.fontFamily" = "'Fira Code', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "editor.lineNumbers" = "relative";

      "terminal.integrated.defaultProfile.osx" = "fish";
      "terminal.integrated.profiles.osx" = {
        fish = {
          path = "${pkgs.fish}/bin/fish";
          args = ["-i" "-l"];
        };
      };

      "workbench.colorTheme" = "Paraíso (dark)";
      "workbench.sideBar.location" = "right";

      "[typescript][json][javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "typescript.preferences.useAliasesForRenames" = false;

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

      "chat.agent.enabled" = true;

      "cSpell.language" = "en-AU,en-GB";
      "cSpell.enabledLanguageIds" = [
        "markdown"
        "text"
        "typescript"
        "javascript"
        "nix"
        "lua"
        "fish"
        "bash"
        "shell"
        "yaml"
        "json"
        "jsonc"
      ];

      "github.copilot.editor.enableAutoCompletions" = true;
      "github.copilot.advanced" = {
        "inlineSuggestEnable" = true;
        "listCount" = 10;
        "length" = 500;
      };

      "github.copilot.chat.welcomeMessage" = "Always use Australian English spelling and grammar (e.g., 'colour' not 'color', 'centre' not 'center', 'behaviour' not 'behavior', 'licence' not 'license', 'optimise' not 'optimize', 'initialise' not 'initialize', 'centralise' not 'centralize').";

      "vsicons.dontShowNewVersionMessage" = true;
    };
  };
}
