_: let
  defaults = import ../lib/defaults.nix;
in {
  imports = [
    ./git.nix
    ./github.nix
    ./fish.nix
    ./starship.nix
    ./neovim.nix
    ./kitty.nix
    ./bat.nix
    ./fzf.nix
    ./direnv.nix
    ./vscode.nix
    ./bash.nix
    ./environment.nix
    ./helix.nix
    ./pgcli.nix
    ./vifm.nix
    ./opnix.nix
    ./1password-ssh.nix
    ./claude-code.nix
    ./jujutsu.nix
  ];

  nix.settings.experimental-features = defaults.nix.experimentalFeatures;

  # nixpkgs.config and overlays are NOT set here — home-manager.useGlobalPkgs = true
  # inherits them from the system configuration
}
