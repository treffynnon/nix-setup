{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables = {
    DEVELOPER = "sholywell";
    # mkForce: new home-manager neovim module also sets VISUAL; we prefer helix
    VISUAL = lib.mkForce "${pkgs.helix}/bin/hx";
    # allow ad-hoc nix commands (nix-shell, nix-env, nix-build) to use unfree
    # packages like terraform (BSL 1.1). for flake commands (nix shell/run/develop)
    # this env var requires `--impure` to take effect.
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
