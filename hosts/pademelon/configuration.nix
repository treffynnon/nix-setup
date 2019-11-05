{ pkgs, ... }:

{
  environment.systemPackages =
      (
        with pkgs; [
          displayplacer
        ]
      );
}
