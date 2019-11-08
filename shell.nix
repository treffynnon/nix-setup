let
  pkgs = import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
      sha256 = "0bxb2qlp9cf1g78pa2mqllp7d0s0n8ypr7m39q3rl76adlmkr8qa";
    }
  ) {};

  inherit (builtins) currentSystem;
  inherit (pkgs.lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;

  luaFormat = import ./codestyle/lua-format.nix { inherit pkgs; };
  nixLinter = import ./codestyle/nix-linter.nix {};
  nixpkgsFmt = import ./codestyle/nixpkgs-fmt.nix { inherit pkgs; };
  luaCheck = import ./codestyle/luacheck.nix { inherit pkgs; };

  luaBusted = (if isDarwin then (pkgs.writeShellScriptBin "busted-install" ''
    if ! [ -x "$(command -v $HOME/.luarocks/bin/busted)" ]; then
      echo "Installing busted..."
      ${pkgs.luarocks-nix}/bin/luarocks install busted --local
    else
      echo "Busted already installed."
    fi
  '') else (pkgs.lua.withPackages(ps: with ps; [ busted ])));
in
  with pkgs;
  stdenv.mkDerivation {
    name = "nix-setup";
    buildInputs = [
      bashInteractive
      luaFormat.LuaFormatter
      nixLinter
      nixpkgsFmt
      luarocks-nix
      luaBusted
      luaCheck
      (pkgs.lua.withPackages (ps: with ps; [ inspect ]))
    ];
    shellHook = ''
      if [ -x "$(command -v ${luaBusted}/bin/busted-install)" ]; then
        ${luaBusted}/bin/busted-install
        if [ -x "$(command -v $HOME/.luarocks/bin/busted)" ]; then
          export PATH="$PATH:$HOME/.luarocks/bin"
        fi
      fi
    '';
  }
