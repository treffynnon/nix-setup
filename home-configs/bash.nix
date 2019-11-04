{ pkgs, ... }:

let
  aliases = (import ./common/aliases.nix) { inherit pkgs; };
in
{
  programs.bash = {
    enable = true;
    # using starship instead of a custom PS1 now
    # sessionVariables = {
    #   PS1="\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[1;34m\] @ \[\033[1;34m\]\h \w\[\033[0;32m\]\$(__git_ps1)\n\[\033[0;32m\]└─\[\033[0m\033[0;32m\]\[\033[0m\033[0;32m\] λ\[\033[0m\] ";
    # };
    shellAliases = aliases.envAliases;

    # hopefully this will be fixed soon so that home-manager doesn't lose the nix initialisation for bash
    # https://github.com/rycee/home-manager/pull/797/files
    initExtra = ''
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi # added by Nix installer
      if [ -e "$HOME/.env" ]; then
        set -a
          source "$HOME/.env"
        set +a
      fi
    '';
  };
  programs.starship.enableBashIntegration = true;
}
