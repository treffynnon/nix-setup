#!/usr/bin/env bash
echo "Formatting Hammerspoon lua code"
find ../home-configs/hammerspoon -type f -name "*.lua" -exec lua-format -c ./lua-format-config.yml {} +

echo "Formatting nix files"
nixpkgs-fmt --check ../**/*.nix

echo "Linting lua code"
echo "Not yet implemented"

echo "Linting nix files"
nix-linter ../**/*.nix
