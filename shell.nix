let
  pkgs = import <nixpkgs> {};

  luaFormat = import ./codestyle/lua-format.nix { inherit pkgs; };
  nixLinter = import ./codestyle/nix-linter.nix { inherit pkgs; };
  nixpkgsFmt = import ./codestyle/nixpkgs-fmt.nix { inherit pkgs; };
  luaCheck = import ./codestyle/luacheck.nix { inherit pkgs; };
in
  with pkgs;
  stdenv.mkDerivation {
    name = "nix-setup";
    buildInputs = [
      bashInteractive
      statix
      nixpkgsFmt
      # luarocks-nix
      (pkgs.lua.withPackages(ps: with ps; [ busted luafilesystem luacheck ]))
      luaformatter
    ];
  }
