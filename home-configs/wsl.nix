{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./git.nix
    ./github.nix
    ./fish.nix
    ./starship.nix
    ./neovim.nix
    ./bat.nix
    ./fzf.nix
    ./direnv.nix
    ./bash.nix
    ./environment.nix
    ./helix.nix
    ./opnix.nix
    ./jujutsu.nix
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
