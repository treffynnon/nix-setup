{pkgs, ...}: let
  defaults = import ../lib/defaults.nix;
in {
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        name = defaults.user.fullName;
        inherit (defaults.user) email;
      };

      ui = {
        editor = "nvim";
        pager = "${pkgs.delta}/bin/delta";
        paginate = "auto";
      };

      signing = {
        sign-all = true;
        backend = "ssh";
        key = "~/${defaults.paths.sshSigningKey}";
      };

      experimental-advance-branches = {
        enabled-branches = ["glob:*"];
        disabled-branches = ["master" "main"];
      };
    };
  };
}
