let
  pkgs = import (
    builtins.fetchTarball {
      name = "nix-master-d793d53b0d829";
      url = https://github.com/NixOS/nixpkgs/archive/d793d53b0d829090b8a38b14384dfcaae9ab1ae5.tar.gz;
      sha256 = "09pz7wkk4w4kwifzwdjwxpqdqqb8g1nd2i4kwdlx8jg8ydb44pm8";
    }
  ) {};

  luaFormat = import ./codestyle/lua-format.nix { inherit pkgs; };
  nixLinter = import ./codestyle/nix-linter.nix {};
  nixpkgsFmt = import ./codestyle/nixpkgs-fmt.nix { inherit pkgs; };
  luaCheck = import ./codestyle/luacheck.nix { inherit pkgs; };
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
      (pkgs.lua.withPackages(ps: with ps; [ busted ]))
      luaCheck
    ];
  }
