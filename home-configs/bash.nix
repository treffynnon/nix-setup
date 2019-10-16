{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    sessionVariables = {
      DEVELOPER="sholywell";
      VISUAL="${pkgs.neovim}/bin/nvim";
      EDITOR="${pkgs.neovim}/bin/nvim";
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

# PATH="$PATH:/Users/simon/.local/bin"
# GIT_PS1_SHOWDIRTYSTATE=true
# export PS1='\u \w$(__git_ps1) 𝝺 '
# export PS1="\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[1;34m\] @ \[\033[1;34m\]\h \w\[\033[0;32m\]\$(__git_ps1)\n\[\033[0;32m\]└─\[\033[0m\033[0;32m\]\[\033[0m\033[0;32m\] λ\[\033[0m\] "
# export DEVELOPER='sholywell'
# export VISUAL="/usr/bin/env nvim"
# export EDITOR="$VISUAL"
}
