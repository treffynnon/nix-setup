#!/usr/bin/env bash
NIXPKGS_BASEPATH=$(realpath `dirname "$0"`/../)

echo "Linting lua code"
lint-lua
echo "Done."
echo " "

echo "Linting nix files"
lint-nix
echo "Done."
echo " "

echo "Formatting Hammerspoon lua code"
format-lua
echo "Done."
echo " "

echo "Formatting nix files"
format-nix
echo "Done."
echo " "
