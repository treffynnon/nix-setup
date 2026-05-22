{pkgs, lib, ...}: {
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    hosts."github.com" = {
      user = "treffynnon";
      git_protocol = "ssh";
    };
    gitCredentialHelper.enable = false;
  };

  home.sessionVariables.OP_PLUGINS_SOURCED = "1";

  programs.fish.interactiveShellInit = lib.mkAfter ''
    function gh --wraps gh --description "1Password Shell Plugin for gh"
      op plugin run -- gh $argv
    end
  '';

  programs.bash.initExtra = lib.mkAfter ''
    gh() {
      op plugin run -- gh "$@";
    }
  '';
}
