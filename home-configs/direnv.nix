let
  nixDirenvPath = (builtins.fetchGit {
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

    home.file.".nix-direnv/direnvrc".source = "${nixDirenvPath}/direnvrc";
    stdlib = builtins.readFile ./direnv/.direnvrc;
  };
}
