{ pkgs ? import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
      sha256 = "0bxb2qlp9cf1g78pa2mqllp7d0s0n8ypr7m39q3rl76adlmkr8qa";
    }
  ) {}
}:
(pkgs.lua.withPackages (ps: with ps; [ luafilesystem luacheck ]))
