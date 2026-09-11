{pkgs, ...}: let
  # The Key Light Neo is plugged into USB, where it speaks HID rather than the
  # Elgato HTTP API. Hammerspoon cannot write HID reports, so it shells out to
  # this helper.
  elgatoUsb = pkgs.writers.writePython3Bin "elgato-usb" {
    libraries = [pkgs.python3Packages.hidapi];
  } (builtins.readFile ../scripts/elgato-usb.py);
in {
  home.packages = [
    pkgs.uhubctl
    elgatoUsb
  ];

  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };

  # Hammerspoon needs an absolute path to run the helper
  home.file.".hammerspoon/nix-paths.lua".text = ''
    return {elgatoUsb = "${elgatoUsb}/bin/elgato-usb"}
  '';
}
