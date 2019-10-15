{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.Firefox; # comes from the overlay 30-apps.nix
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      darkreader
      https-everywhere
      privacy-badger
      refined-github
      ublock-origin
    ];
  };
}
