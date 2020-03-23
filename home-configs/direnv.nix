let
  nixDirenvPath = (
    builtins.fetchTarball {
      name = "nix-direnv";
      url = https://github.com/nix-community/nix-direnv/archive/ea98d4112dc38867fb02db54c8bf8b57d9bf16ac.tar.gz;
      sha256 = "11acf8s1r2ibjmjd6kv09nm1bydkvapkxc7yvwdk2861v5a2l68i";
    }
  );
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
