{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  aliases = (import ./common/aliases.nix) {inherit pkgs;};
in
  # waiting for https://github.com/rycee/home-manager/pull/635 to be merged
  {
    programs.fish = {
      enable = true;
      shellAbbrs = aliases.envAliases;

      # nix-darwin
      # $PATH is broken for fish shell
      # https://github.com/LnL7/nix-darwin/issues/122
      # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      loginShellInit = let
        # This naive quoting is good enough in this case. There shouldn't be any
        # double quotes in the input string, and it needs to be double quoted in case
        # it contains a space (which is unlikely!)
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';

      plugins = [
      ];
    };

    # https://discourse.nixos.org/t/bootstrapping-new-system/3455/9
    xdg = {
      configFile."fish/conf.d" = {
        source = ./fish/conf.d;
        recursive = true;
      };
      configFile."fish/functions" = {
        source = ./fish/functions;
        recursive = true;
      };
    };
    xdg.configFile."fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
  }
