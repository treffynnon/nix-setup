let
  pkgs = import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
      sha256 = "0bxb2qlp9cf1g78pa2mqllp7d0s0n8ypr7m39q3rl76adlmkr8qa";
    }
  ) {};

  luaFormat = import ./codestyle/lua-format.nix { inherit pkgs; };
  nixLinter = import ./codestyle/nix-linter.nix {};
  nixpkgsFmt = import ./codestyle/nixpkgs-fmt.nix { inherit pkgs; };
  luaCheck = import ./codestyle/luacheck.nix { inherit pkgs; };
  luaSystemNoGlibc = pkgs.luaPackages.luasystem.override({
    buildInputs = [];
  });
  bustedNoGlibc = with pkgs; luaPackages.busted.override({
    propagatedBuildInputs = with luaPackages; [ lua lua_cliargs luafilesystem luaSystemNoGlibc dkjson say luassert lua-term penlight mediator_lua ];
  });
  luaBusted = (pkgs.lua.withPackages(ps: with ps; [ bustedNoGlibc ])).override(args: {
    ignoreCollisions = true;
  });
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
    ];
  }
