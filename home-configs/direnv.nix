let
  nixDirenvPath = (builtins.fetchTarball {
    name = "nix-direnv";
    url = https://github.com/nix-community/nix-direnv/archive/e7df598cd0addefb51b678a2a4b1607942f153e7.tar.gz;
    sha256 = "0bj561c0qawadd62n1xidxkv6zdmdb39zhyvl2l9x2l62j1abriw";
  });
in
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  # https://github.com/nix-community/nix-direnv
  home.file.".nix-direnv/direnvrc".source = "${nixDirenvPath}/direnvrc";
  xdg.configFile."direnv/direnvrc".source = ./direnv/.direnvrc;
}
