let
  # nix1809 = import (builtins.fetchGit {
  #   name = "nixos-18_09";
  #   url = https://github.com/NixOS/nixpkgs.git;
  #   ref = "refs/tags/18.09";
  # }) {};
  nix1809 = import (
    builtins.fetchTarball {
      name = "nixos-18_09";
      url = https://github.com/NixOS/nixpkgs/archive/18.09.tar.gz;
      sha256 = "1ib96has10v5nr6bzf7v8kw7yzww8zanxgw2qi1ll1sbv6kj6zpd";
    }
  ) {};
in

  with import <nixpkgs> {};
  stdenv.mkDerivation {
    name = "ftr-beast";
    buildInputs = [
      bashInteractive
      nix1809.nodejs-8_x
    ];
  }
