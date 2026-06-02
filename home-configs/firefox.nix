{pkgs, ...}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.firefox = {
    enable = !isDarwin; # package is unavailable for Mac
    package = pkgs.firefox;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      darkreader
      https-everywhere
      privacy-badger
      refined-github
      ublock-origin
    ];
  };
}
