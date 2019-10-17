let
  nixDirenvPath = (builtins.fetchGit {
    name = "nix-direnv";
    url = https://github.com/nix-community/nix-direnv.git;
    rev = "e7df598cd0addefb51b678a2a4b1607942f153e7";
    ref = "master";
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
