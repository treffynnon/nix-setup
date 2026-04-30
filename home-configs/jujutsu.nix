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
        pager = pkgs.delta;
        paginate = "auto";
      };
    };
  };
}
