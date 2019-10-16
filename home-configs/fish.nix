{
  programs.fish = {
    enable = true;
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."fish/config.fish".source = ./fish/config.fish;
  xdg.configFile."fish/functions" = {
    source = ./fish/functions;
    recursive = true;
  };
}
