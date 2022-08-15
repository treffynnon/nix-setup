{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    # no longer required as it is always enabled in fish
    # enableFishIntegration = true;
  };
}
