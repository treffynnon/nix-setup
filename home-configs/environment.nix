{pkgs, lib, ...}: {
  home.sessionVariables = {
    DEVELOPER = "sholywell";
    # mkForce: new home-manager neovim module also sets VISUAL; we prefer helix
    VISUAL = lib.mkForce "${pkgs.helix}/bin/hx";
  };
}
