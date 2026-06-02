{opnix, ...}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
    ./hammerspoon.nix
  ];
}
