{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  programs.firefox = {
    enable = true;
    package = if isDarwin then pkgs.Firefox else pkgs.firefox; # comes from the overlay 30-apps.nix
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      darkreader
      https-everywhere
      privacy-badger
      refined-github
      ublock-origin
    ];
  };
}
