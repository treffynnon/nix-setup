# Platform detection utilities and helpers
{ lib, pkgs, ... }:
let
  inherit (lib) optionals optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux system;
in {
  # Enhanced platform detection
  platform = {
    inherit isDarwin isLinux system;
    isMacOS = isDarwin;
    isAarch64 = pkgs.stdenv.hostPlatform.isAarch64;
    isX86_64 = pkgs.stdenv.hostPlatform.isx86_64;
    
    # Convenient platform strings
    platformName = 
      if isDarwin then "darwin"
      else if isLinux then "linux"
      else "unknown";
    
    # Architecture strings
    arch = pkgs.stdenv.hostPlatform.system;
  };

  # Platform-specific conditionals (returns lists)
  onDarwin = list: optionals isDarwin list;
  onLinux = list: optionals isLinux list;
  onMacOS = list: optionals isDarwin list;
  onAarch64 = list: optionals pkgs.stdenv.hostPlatform.isAarch64 list;
  onX86_64 = list: optionals pkgs.stdenv.hostPlatform.isx86_64 list;

  # Platform-specific conditionals (returns single values)
  ifDarwin = then_: else_: if isDarwin then then_ else else_;
  ifLinux = then_: else_: if isLinux then then_ else else_;
  ifMacOS = then_: else_: if isDarwin then then_ else else_;

  # Home directory helper
  homeDir = username: 
    if isDarwin 
    then "/Users/${username}"
    else "/home/${username}";

  # Platform-specific packages helper
  platformPackages = packages: 
    let
      common = packages.common or [];
      darwin = packages.darwin or [];
      linux = packages.linux or [];
      aarch64 = packages.aarch64 or [];
      x86_64 = packages.x86_64 or [];
    in 
      common 
      ++ (optionals isDarwin darwin)
      ++ (optionals isLinux linux)
      ++ (optionals pkgs.stdenv.hostPlatform.isAarch64 aarch64)
      ++ (optionals pkgs.stdenv.hostPlatform.isx86_64 x86_64);

  # Smart module selection helper
  platformModules = modules:
    let
      common = modules.common or [];
      darwin = modules.darwin or [];
      linux = modules.linux or [];
    in
      common
      ++ (optionals isDarwin darwin)
      ++ (optionals isLinux linux);

  # Configuration merging helper
  platformConfig = configs:
    let
      common = configs.common or {};
      darwin = configs.darwin or {};
      linux = configs.linux or {};
    in
      common
      // (if isDarwin then darwin else {})
      // (if isLinux then linux else {});
}
