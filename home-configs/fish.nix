{ pkgs, config, ...}:

# waiting for https://github.com/rycee/home-manager/pull/635 to be merged

{
  programs.fish = {
    enable = true;
    # nix-darwin
    # $PATH is broken for fish shell
    # https://github.com/LnL7/nix-darwin/issues/122
    shellInit = ''
      for p in /run/current-system/sw/bin $HOME/.nix-profile/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin
        if not contains $p $fish_user_paths
          set -g fish_user_paths $p $fish_user_paths
        end
      end
    '';
  };

  # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
  xdg.configFile."fish/conf.d" = {
    source = ./fish/conf.d;
    recursive = true;
  };
  xdg.configFile."fish/functions" = {
    source = ./fish/functions;
    recursive = true;
  };
}
