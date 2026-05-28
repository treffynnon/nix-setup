{opnix, ...}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
    ./hammerspoon.nix
    ./1password-ssh.nix
  ];
}
