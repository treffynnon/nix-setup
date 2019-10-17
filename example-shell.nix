let
  nix1809 = import (builtins.fetchGit {
    name = "nixos-18_09";
    url = https://github.com/NixOS/nixpkgs.git;
    ref = "refs/tags/18.09";
  }) {};
in

with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "ftr-beast";
  buildInputs = [
    bashInteractive
    nix1809.nodejs-8_x
  ];
}

