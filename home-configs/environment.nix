{pkgs, ...}: {
  home.sessionVariables = {
    DEVELOPER = "sholywell";
    VISUAL = "${pkgs.helix}/bin/hx";
    EDITOR = "${pkgs.helix}/bin/hx";
  };
}
