let
  pkgs = import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
    }
  ) {};
  luaFormat = import ./ci/lua-format.nix { inherit pkgs; };
  nixLinter = import ./ci/nix-linter.nix {};
  nixpkgsFmt = import ./ci/nixpkgs-fmt.nix { inherit pkgs; };
in

  with pkgs;
  stdenv.mkDerivation {
    name = "nix-setup";
    buildInputs = [
      bashInteractive
      luaFormat.LuaFormatter
      nixLinter
      nixpkgsFmt
    ];
  }
