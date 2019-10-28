{ pkgs ? import (
    builtins.fetchTarball {
    name = "nix-linter-master-f86bcb5a12";
    url = https://github.com/Synthetica9/nix-linter/archive/f86bcb5a12fa0e99473c3f58d1b2ef70acb10bbb.tar.gz;
  }
  ) {}
}:
pkgs.nix-linter
