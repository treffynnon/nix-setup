{pkgs, ...}: {
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        name = "Simon Holywell";
        email = "simon@holywell.au";
      };

      ui = {
        editor = "nvim";
        pager = "${pkgs.delta}/bin/delta";
        paginate = "auto";
      };

      experimental-advance-branches = {
        enabled-branches = ["glob:*"];
        disabled-branches = ["master" "main"];
      };
    };
  };
}
