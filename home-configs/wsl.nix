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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
      };
    };
  };
}
