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

  home.packages = with pkgs; [
    _1password-cli
    bat
    direnv
    eza
    fd
    fzf
    jq
    less
    ripgrep
    unzip
    yq
    zip
  ];

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
