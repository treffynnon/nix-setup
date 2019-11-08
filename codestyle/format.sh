#!/usr/bin/env bash
NIXPKGS_BASEPATH=$(realpath `dirname "$0"`/../)

echo "Formatting Hammerspoon lua code"
find "$NIXPKGS_BASEPATH/home-configs/hammerspoon" -type f -name "*.lua" -exec lua-format -c "$NIXPKGS_BASEPATH/codestyle/lua-format-config.yml" {} +
echo "Done."
echo " "

echo "Formatting nix files"
nixpkgs-fmt "$NIXPKGS_BASEPATH"/**/*.nix
echo "Done."
echo " "

echo "Linting lua code"
luacheck --globals hs spoon --no-max-line-length "$NIXPKGS_BASEPATH/home-configs/hammerspoon"
echo "Done."
echo " "

echo "Linting nix files"
nix-linter "$NIXPKGS_BASEPATH"/**/*.nix
echo "Done."
echo " "
