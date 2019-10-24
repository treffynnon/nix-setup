{ pkgs, config, ... }:

let
  configDir = "$HOME/.config/httpie";
  configData = {
    default_options = [ "--style=paraiso-dark" ];
  };
in
{
  # Note that httpie version is overriden in overlays. This is because HTTPie tries to
  # write to its configuration file in the current version, but the pre-release version
  # in master does not. Obviously, when installed via Nix the configuration directory
  # is not writable so the currently released version throws an exception and dies.
  home.packages = with pkgs; [
    httpie
  ];

  # HTTPie tries to write to this file for some bloody reason and it's locked by nix
  # if there is some way to stop that then this would be a much better way of doing the configuration
  home.sessionVariables = {
    HTTPIE_CONFIG_DIR = configDir;
  };

  xdg.configFile."httpie/config.json".text = builtins.toJSON(configData);
}
