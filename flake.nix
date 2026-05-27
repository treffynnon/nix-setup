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
    currentSystem = builtins.currentSystem or "aarch64-darwin";
    darwinConfiguration = import ./darwin-configuration.nix;
    nixosConfiguration = import ./nixos-configuration.nix;
    homeManagerConfiguration = import ./home-manager-configuration.nix;

    mkDarwinHost = {
      system ? currentSystem,
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
      darwinConfigurations = {
        default = mkDarwinHost {};
        bilby = mkDarwinHost {
          extraModules = [./hosts/bilby/configuration.nix];
        };
        gecko = mkDarwinHost {
          extraModules = [./hosts/gecko/configuration.nix];
        };
        pademelon = mkDarwinHost {
          extraModules = [./hosts/pademelon/configuration.nix];
        };
        platypus = mkDarwinHost {
          extraModules = [./hosts/platypus/configuration.nix];
        };
        thylacine = mkDarwinHost {
          extraModules = [./hosts/thylacine/configuration.nix];
        };
      };

      nixosConfigurations = {
        default = mkNixosHost {
          system = "x86_64-linux";
        };
        default-arm64 = mkNixosHost {
          system = "aarch64-linux";
        };
        nixos-vm = mkNixosHost {
          system = "x86_64-linux";
        };
      };

      homeConfigurations = {
        "simon@default" = mkHome {
          system = "x86_64-linux";
          extraModules = [./home-configs/linux.nix];
        };
        "simon@default-arm64" = mkHome {
          system = "aarch64-linux";
          extraModules = [./home-configs/linux.nix];
        };
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

        # Darwin rebuild script with auto-detection
        darwinRebuild = pkgs.writeScriptBin "darwin-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          HOSTNAME=$(hostname || echo "default")
          echo "Auto-detected hostname: $HOSTNAME"

          # Check if host-specific configuration exists
          if [ -f "./hosts/$HOSTNAME/configuration.nix" ]; then
            echo "Found host-specific configuration for $HOSTNAME"
            echo "Rebuilding Darwin configuration for $HOSTNAME..."
            sudo darwin-rebuild switch --flake .#$HOSTNAME
          else
            echo "No host-specific configuration found for $HOSTNAME"
            echo "Available hosts: bilby, pademelon, platypus, thylacine"
            echo "Falling back to default configuration..."
            sudo darwin-rebuild switch --flake .#default
          fi
        '';

        # NixOS rebuild script
        nixosRebuild = pkgs.writeScriptBin "nixos-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          HOSTNAME=$(hostname || echo "default")
          echo "Auto-detected hostname: $HOSTNAME"
          echo "Rebuilding NixOS configuration..."
          sudo nixos-rebuild switch --flake .#$HOSTNAME || sudo nixos-rebuild switch --flake .#default
        '';

        # Home Manager rebuild script
        homeManagerRebuild = pkgs.writeScriptBin "home-manager-rebuild-flake" ''
          #!${pkgs.bash}/bin/bash
          USER=$(whoami)
          HOSTNAME=$(hostname || echo "default")

          echo "Rebuilding Home Manager configuration for $USER@$HOSTNAME..."

          # Try specific user@hostname combinations first
          if home-manager switch --flake .#$USER@$HOSTNAME 2>/dev/null; then
            echo "Successfully applied $USER@$HOSTNAME configuration"
          elif home-manager switch --flake .#$USER@linux 2>/dev/null; then
            echo "Successfully applied $USER@linux configuration"
          elif home-manager switch --flake .#$USER@default 2>/dev/null; then
            echo "Successfully applied $USER@default configuration"
          else
            echo "Failed to find suitable Home Manager configuration"
            echo "Available configurations: simon@default, simon@wsl, simon@linux"
            exit 1
          fi
        '';

        # Universal rebuild script that detects platform
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
            echo "Install nix-darwin, NixOS, or home-manager first"
            exit 1
          fi
        '';

        # Auto-rebuild script (uses current hostname)
        autoRebuild = pkgs.writeScriptBin "auto-rebuild" ''
          #!${pkgs.bash}/bin/bash
          HOSTNAME=$(hostname || echo "default")
          echo "Auto-rebuilding for hostname: $HOSTNAME"

          if [[ "$OSTYPE" == "darwin"* ]]; then
            sudo darwin-rebuild switch --flake .#$HOSTNAME
          else
            echo "Auto-rebuild currently only supports macOS"
            echo "Use 'rebuild' for cross-platform rebuilding"
            exit 1
          fi
        '';

        # Host-specific rebuild scripts
        rebuildHost = pkgs.writeScriptBin "rebuild-host" ''
          #!${pkgs.bash}/bin/bash
          if [ -z "$1" ]; then
            echo "Usage: rebuild-host <hostname>"
            echo "Available hosts: bilby, pademelon, platypus, thylacine"
            exit 1
          fi
          echo "Rebuilding Darwin configuration for $1..."
          sudo darwin-rebuild switch --flake .#$1
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

        # needed at run time
        buildInputs = with pkgs; [
          bashInteractive
          alejandra # nix fomatter
          statix # nix linter
          deadnix
          (lua.withPackages (ps: with ps; [busted luafilesystem luacheck]))
          luaformatter
          uhubctl # USB hub control utility

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
          autoRebuild
          rebuildHost
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
            inherit buildInputs nativeBuildInputs;
          };
        }
    );
}
