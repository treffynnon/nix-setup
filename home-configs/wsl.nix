{
  pkgs,
  opnix,
  ...
}: {
  imports = [
    opnix.homeManagerModules.default
    ./shared.nix
  ];

  _1password.platform = "wsl";

  home.packages = import ../lib/cli-packages.nix pkgs;

  home.file.".ssh/config.d/20-wsl" = {
    text = ''
      Host *
        ForwardAgent yes
        AddKeysToAgent no
        Compression no
        ServerAliveInterval 0
    '';
  };
}
