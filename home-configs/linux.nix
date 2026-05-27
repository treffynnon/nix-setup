{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
  ];

  home.packages = with pkgs; [
    _1password-cli
  ];
}
