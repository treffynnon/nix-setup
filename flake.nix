{
  description = "nix-setup";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        overlays = [
          # (import rust-overlay)
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # needed at compile time
        nativeBuildInputs = with pkgs; [];

        # sets up scripts that can easily be called on the command line
        lintLua = pkgs.writeScriptBin "lint-lua" ''
          #!${pkgs.bash}/bin/bash
          luacheck --config ./codestyle/.luacheckrc.lua "./home-configs/hammerspoon"
        '';
        formatLua = pkgs.writeScriptBin "format-lua" ''
          #!${pkgs.bash}/bin/bash
           find "./home-configs/hammerspoon" -type f -name "*.lua" -exec ${pkgs.luaformatter}/bin/lua-format -i --config="./codestyle/lua-format-config.yml" {} +
        '';

        lintNix = pkgs.writeScriptBin "lint-nix" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.statix}/bin/statix check ./ -i .direnv
        '';
        formatNix = pkgs.writeScriptBin "format-nix" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.alejandra}/bin/alejandra --exclude .direnv .
        '';
        ciFormatNix = pkgs.writeScriptBin "ci-format-nix" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.alejandra}/bin/alejandra --check --exclude .direnv .
        '';

        runAllLintersAndFormatters = pkgs.writeScriptBin "format" ''
          #!${pkgs.bash}/bin/bash
          echo "Linting lua code"
          lint-lua
          echo "Done."
          echo " "

          echo "Linting nix files"
          lint-nix
          echo "Done."
          echo " "

          echo "Formatting Hammerspoon lua code"
          format-lua
          echo "Done."
          echo " "

          echo "Formatting nix files"
          format-nix
          echo "Done."
          echo " "
        '';

        # needed at run time
        buildInputs = with pkgs; [
          bashInteractive
          alejandra # nix fomatter
          statix # nix linter
          (lua.withPackages (ps: with ps; [busted luafilesystem luacheck]))
          luaformatter

          lintLua
          formatLua
          lintNix
          formatNix
          ciFormatNix
          runAllLintersAndFormatters
        ];
      in
        with pkgs; {
          devShells.default = mkShell {
            name = "nix-setup";
            inherit buildInputs nativeBuildInputs;
          };
        }
    );
}
