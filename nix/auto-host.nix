{lib, ...}: let
  inherit (builtins) pathExists;
  inherit (lib) flatten;

  hostName = import ./hostname.nix {inherit lib;};
  optionalPath = file:
    if (pathExists file)
    then [file]
    else [];
in {
  networking.hostName = hostName;

  imports = flatten [
    (../. + "/hosts/${hostName}/configuration.nix")
    (optionalPath (../. + "/hosts/${hostName}/hardware-configuration.nix"))
    (optionalPath (../. + "/hosts/${hostName}/private-configuration.nix"))
  ];
}
