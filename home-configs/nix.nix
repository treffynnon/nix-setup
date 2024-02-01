{
  nix = {
    # enables access to experimental flakes support
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
}
