{ pkgs, ... }:

let
  fishFzfKeybindings = (
    builtins.fetchGit {
      name = "fzf-fish-keybindings";
      url = https://github.com/jethrokuan/fzf.git;
      rev = "ac01d96fc6344ebeb48c03f2c9c0be5bf3b20f1c";
      ref = "master";
    }
  );
  aliases = (import ./common/aliases.nix) { inherit pkgs; };
in

  # waiting for https://github.com/rycee/home-manager/pull/635 to be merged

{
  programs.fish = {
    enable = true;
    # nix-darwin
    # $PATH is broken for fish shell
    # https://github.com/LnL7/nix-darwin/issues/122
    shellInit = ''
      # any-nix-shell fish --info-right | source
      # for p in /run/current-system/sw/bin $HOME/.nix-profile/bin /etc/profiles/per-user/$USER/bin /nix/var/nix/profiles/default/bin
      #   if not contains $p $fish_user_paths
      #     set -g fish_user_paths $p $fish_user_paths
      #   end
      # end
      set -U FZF_LEGACY_KEYBINDINGS 0
    '';
    shellAbbrs = aliases.envAliases;
  };

  xdg.configFile."fish/conf.d/fzf.fish".text = ''
    set fish_function_path ${fishFzfKeybindings}/functions $fish_function_path
    for p in ${fishFzfKeybindings}/conf.d/*.fish
      source $p
    end
  '';

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
