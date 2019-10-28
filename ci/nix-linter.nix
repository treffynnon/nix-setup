let
  nixMaster = import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
    }
  ) {};
in

  with import <nixpkgs> {





  };
  stdenv.mkDerivation {
    name = "nix-setup-ci";
    buildInputs = [
      nixMaster.nixpkgs-fmt
    ];
  }
