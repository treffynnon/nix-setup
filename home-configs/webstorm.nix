{ pkgs, ... }:

{
  home.packages = [(pkgs.writeScriptBin "storm" ''
    #!/usr/bin/env bash
    open -na "WebStorm.app" --args --nosplash .
  '')];
}
