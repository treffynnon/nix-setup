{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    stdlib = builtins.readFile ./direnv/.direnvrc;
  };
}
