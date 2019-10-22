{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    httpie
  ];

  programs.fish.shellAbbrs = {
    http = "http --style=paraiso-dark";
  };

  # HTTPie tries to write to this file for some bloody reason and it's locked by nix
  # if there is some way to stop that then this would be a much better way of doing the
  # configuration
  # home.sessionVariables = {
  #   HTTPIE_CONFIG_DIR = "$HOME/.config/httpie";
  # };

  # xdg.configFile."httpie/config.json".text = ''
  #   {
  #     "default_options": [""]
  #   }
  # '';
}
