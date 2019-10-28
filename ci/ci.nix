# { nixpkgsCommit ? "d16a5a5916852d54ba60ca1c408d52786f38aa67"
# , nixpkgsURL ? "https://github.com/NixOS/nixpkgs/archive/${nixpkgsCommit}.tar.gz"
# , pkgsPath ? builtins.fetchTarball nixpkgsURL
# , pkgs ? import pkgsPath {}
# }:
# with pkgs;

# (haskellPackages.override ({
#     overrides = self: super: {
#       streamly = super.streamly_0_5_2 or super.streamly_0_5_0 or super.streamly;
#       path-io = super.path-io_1_4_0 or super.path-io;
#     };
# })).extend (haskell.lib.packageSourceOverrides {
#   nix-linter = builtins.fetchTarball https://github.com/Synthetica9/nix-linter/archive/f86bcb5a12fa0e99473c3f58d1b2ef70acb10bbb.zip;
# })
# // {
#   inherit pkgs;
# }


let
  nixMaster = import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
    }
  ) {};
in

  with import <nixpkgs> {};
  stdenv.mkDerivation {
    name = "nix-setup-ci";
    buildInputs = [
      nixMaster.nixpkgs-fmt
    ];
  }
