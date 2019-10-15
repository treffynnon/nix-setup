{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      darkreader
      https-everywhere
      refined-github
      ublock-origin
    ];
  };
}
