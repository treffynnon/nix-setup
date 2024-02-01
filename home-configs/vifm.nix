{pkgs, ...}: let
  configDir = "$HOME/.config/vifm";
in {
  home.packages = with pkgs; [
    vifm
  ];

  home.sessionVariables = {
    VIFM = configDir;
    MYVIFMRC = "${configDir}/vifmrc";
  };

  xdg.configFile."vifm" = {
    source = ./vifm;
    recursive = true;
  };
}
