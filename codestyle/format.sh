#!/usr/bin/env bash
NIXPKGS_BASEPATH=$(realpath `dirname "$0"`/../)
echo $NIXPKGS_BASEPATH

echo "Formatting Hammerspoon lua code"
find "$NIXPKGS_BASEPATH/home-configs/hammerspoon" -type f -name "*.lua" -exec lua-format -c "$NIXPKGS_BASEPATH/codestyle/lua-format-config.yml" {} +

echo "Formatting nix files"
nixpkgs-fmt --check "$NIXPKGS_BASEPATH"/**/*.nix

echo "Linting lua code"
echo "Not yet implemented"

echo "Linting nix files"
nix-linter "$NIXPKGS_BASEPATH"/**/*.nix
