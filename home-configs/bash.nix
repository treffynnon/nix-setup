{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    sessionVariables = {
      DEVELOPER="sholywell";
      VISUAL="${pkgs.neovim}/bin/nvim";
      EDITOR="${pkgs.neovim}/bin/nvim";
      GIT_PS1_SHOWDIRTYSTATE = true;
      # PS1="\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[1;34m\] @ \[\033[1;34m\]\h \w\[\033[0;32m\]\$(__git_ps1)\n\[\033[0;32m\]└─\[\033[0m\033[0;32m\]\[\033[0m\033[0;32m\] λ\[\033[0m\] ";
    };
    shellAliases = {
      ls = "ls -G";
      ll = "ls -Glkha";
      icat = "${pkgs.kitty}/bin/kitty +kitten icat";
      d = "${pkgs.kitty}/bin/kitty +kitten diff";
      gd = "git difftool --no-symlinks --dir-diff";
      pcat = "pygmentize -f terminal256 -O style=paraiso-dark -g";
    };
  };
  programs.starship.enableBashIntegration = true;

  # hopefully this will be fixed soon so that home-manager doesn't lose the nix initialisation for bash
  # https://github.com/rycee/home-manager/pull/797/files
  programs.bash.initExtra = ''
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi # added by Nix installer
  '';
}
