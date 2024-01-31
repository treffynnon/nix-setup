let
  pkgs = import <nixpkgs> {};
in
  with pkgs;
  stdenv.mkDerivation {
    name = "nix-setup";
    buildInputs = [
      bashInteractive
      statix
      nixpkgs-fmt
      (pkgs.lua.withPackages(ps: with ps; [ busted luafilesystem luacheck ]))
      luaformatter
    ];
  }
