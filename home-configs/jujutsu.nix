{
  config,
  lib,
  pkgs,
  ...
}: let
  defaults = import ../lib/defaults.nix;
  opCfg = defaults.onePassword.platforms.${config._1password.platform};
  allowedSignersPath = "~/.ssh/allowed_signers";
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
        show-cryptographic-signatures = true;
      };

      signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/${defaults.paths.sshSigningKey}";
        backends.ssh = {
          program = opCfg.opSshSign;
          allowed-signers = allowedSignersPath;
        };
      };

      experimental-advance-branches = {
        enabled-branches = ["glob:*"];
        disabled-branches = ["master" "main"];
      };
    };
  };

  home.activation.setupJjAllowedSigners = lib.hm.dag.entryAfter ["writeBoundary"] ''
    key="${config.home.homeDirectory}/${defaults.paths.sshSigningKey}"
    out="${config.home.homeDirectory}/.ssh/allowed_signers"
    if [ -f "$key" ]; then
      printf '%s %s\n' "${defaults.user.email}" "$(tr -d '\n' < "$key")" > "$out"
      chmod 0644 "$out"
    fi
  '';
}
