#!/usr/bin/env bash
NIXPKGS_BASEPATH=$(realpath `dirname "$0"`/../)

echo "Linting lua code"
luacheck --config "$NIXPKGS_BASEPATH"/codestyle/.luacheckrc.lua "$NIXPKGS_BASEPATH/home-configs/hammerspoon"
echo "Done."
echo " "

echo "Linting nix files"
nix-linter "$NIXPKGS_BASEPATH"/**/*.nix
echo "Done."
echo " "

echo "Formatting Hammerspoon lua code"
find "$NIXPKGS_BASEPATH/home-configs/hammerspoon" -type f -name "*.lua" -exec lua-format -i --config="$NIXPKGS_BASEPATH/codestyle/lua-format-config.yml" {} +
echo "Done."
echo " "

echo "Formatting nix files"
nixpkgs-fmt "$NIXPKGS_BASEPATH"/**/*.nix
echo "Done."
echo " "
