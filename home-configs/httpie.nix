{ pkgs, config, ... }:

let
  configDir = "$HOME/.config/httpie";
  configData = {
    default_options = [ "--style=paraiso-dark" ];
  };
in
{
  home.packages = with pkgs; [
    httpie
  ];

  # HTTPie tries to write to this file for some bloody reason and it's locked by nix
  # if there is some way to stop that then this would be a much better way of doing the configuration
  home.sessionVariables = {
    HTTPIE_CONFIG_DIR = configDir;
  };

  # HTTPie tries to write to this file for some bloody reason and it's locked by nix
  # if there is some way to stop that then this would be a much better way of doing the
  # xdg.configFile."httpie/config.json".text = builtins.toJson(configData);
  programs.fish.shellAbbrs = {
    http = "http --style=paraiso-dark";
  };
}
