{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
  ];

  home.packages = import ../lib/cli-packages.nix pkgs;
}
