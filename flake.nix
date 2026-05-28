{
  description = "nix-setup";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    darwin,
    determinate,
    home-manager,
    opnix,
  }: let
    hostsDir = ./hosts;
    hostNames = builtins.attrNames (builtins.readDir hostsDir);
    darwinHostNames =
      builtins.filter
      (name: builtins.pathExists (hostsDir + "/${name}/darwin.nix"))
      hostNames;
    nixosHostNames =
      builtins.filter
      (name: builtins.pathExists (hostsDir + "/${name}/nixos.nix"))
      hostNames;
    getHostSystem = name: let
      metaFile = hostsDir + "/${name}/meta.nix";
    in
      if builtins.pathExists metaFile
      then (import metaFile).system or "x86_64-linux"
      else "x86_64-linux";

    darwinConfiguration = import ./darwin-configuration.nix;
    nixosConfiguration = import ./nixos-configuration.nix;
    homeManagerConfiguration = import ./home-manager-configuration.nix;

    mkDarwinHost = {
      system ? "aarch64-darwin",
      extraModules ? [],
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit home-manager opnix;};
        modules =
          [
            determinate.darwinModules.default
            darwinConfiguration
          ]
          ++ extraModules;
      };

    mkNixosHost = {
      system,
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit home-manager opnix;};
        modules = [nixosConfiguration] ++ extraModules;
      };

    mkHome = {
      system,
      extraModules ? [],
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {inherit opnix;};
        modules = [homeManagerConfiguration] ++ extraModules;
      };
  in
    {
      darwinConfigurations = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = mkDarwinHost {
            extraModules = [(hostsDir + "/${name}/darwin.nix")];
          };
        })
        darwinHostNames
      );

      nixosConfigurations = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = mkNixosHost {
            system = getHostSystem name;
            extraModules = [(hostsDir + "/${name}/nixos.nix")];
          };
        })
        nixosHostNames
      );

      homeConfigurations = {
        "simon@wsl" = mkHome {
          system = "x86_64-linux";
          extraModules = [./home-configs/wsl.nix];
        };
        "simon@linux" = mkHome {
          system = "x86_64-linux";
          extraModules = [./home-configs/linux.nix];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {inherit system;};

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
        lintDeadNix = pkgs.writeScriptBin "lint-deadnix" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.deadnix}/bin/deadnix --fail --exclude .direnv .
        '';
        verifyOnePasswordSsh = pkgs.writeScriptBin "verify-1password-ssh" ''
          #!${pkgs.bash}/bin/bash
          exec ./scripts/1password-ssh.sh verify
        '';
        verifyOnePasswordGh = pkgs.writeScriptBin "verify-1password-gh" ''
          #!${pkgs.bash}/bin/bash
          exec ./scripts/1password-gh.sh verify
        '';

        darwinRebuild = pkgs.writeScriptBin "darwin-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          HOSTNAME=$(hostname)
          echo "Auto-detected hostname: $HOSTNAME"
          if [ -f "./hosts/$HOSTNAME/darwin.nix" ]; then
            echo "Rebuilding Darwin configuration for $HOSTNAME..."
            sudo darwin-rebuild switch --flake ".#$HOSTNAME"
          else
            available=$(for d in ./hosts/*/darwin.nix; do basename "$(dirname "$d")"; done | tr '\n' ' ')
            echo "No darwin.nix found for $HOSTNAME."
            echo "Available hosts: $available"
            exit 1
          fi
        '';

        nixosRebuild = pkgs.writeScriptBin "nixos-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          HOSTNAME=$(hostname)
          echo "Auto-detected hostname: $HOSTNAME"
          echo "Rebuilding NixOS configuration..."
          sudo nixos-rebuild switch --flake ".#$HOSTNAME"
        '';

        homeManagerRebuild = pkgs.writeScriptBin "home-manager-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          USER=$(whoami)
          HOSTNAME=$(hostname)
          echo "Rebuilding Home Manager configuration for $USER@$HOSTNAME..."
          if home-manager switch --flake ".#$USER@$HOSTNAME" 2>/dev/null; then
            echo "Successfully applied $USER@$HOSTNAME configuration"
          elif home-manager switch --flake ".#$USER@linux" 2>/dev/null; then
            echo "Successfully applied $USER@linux configuration"
          else
            echo "Failed to find suitable Home Manager configuration"
            echo "Available configurations: simon@linux, simon@wsl"
            exit 1
          fi
        '';

        universalRebuild = pkgs.writeScriptBin "rebuild" ''
          #!${pkgs.bash}/bin/bash
          if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "Detected macOS - using darwin-rebuild"
            darwin-rebuild-flake
          elif command -v nixos-rebuild &> /dev/null; then
            echo "Detected NixOS - using nixos-rebuild"
            nixos-rebuild-flake
          elif command -v home-manager &> /dev/null; then
            echo "Detected home-manager available - using home-manager"
            home-manager-rebuild-flake
          else
            echo "No suitable rebuild command found"
            exit 1
          fi
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

            echo "Checking for dead nix code"
            lint-deadnix
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

        buildInputs = with pkgs; [
          bashInteractive
          alejandra
          statix
          deadnix
          (lua.withPackages (ps: with ps; [busted luafilesystem luacheck]))
          luaformatter
          uhubctl

          lintLua
          formatLua
          lintNix
          lintDeadNix
          formatNix
          ciFormatNix
          darwinRebuild
          nixosRebuild
          homeManagerRebuild
          universalRebuild
          runAllLintersAndFormatters
          verifyOnePasswordSsh
          verifyOnePasswordGh
        ];
      in
        with pkgs; {
          apps.verify-1password-ssh = {
            type = "app";
            program = "${verifyOnePasswordSsh}/bin/verify-1password-ssh";
          };
          apps.verify-1password-gh = {
            type = "app";
            program = "${verifyOnePasswordGh}/bin/verify-1password-gh";
          };
          devShells.default = mkShell {
            name = "nix-setup";
            inherit buildInputs;
          };
        }
    );
}
