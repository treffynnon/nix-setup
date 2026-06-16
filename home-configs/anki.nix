{pkgs, ...}: {
  # anki-bin: official upstream .app bundle (anki fails to build on darwin — qtwebengine)
  home.packages = [pkgs.anki-bin];
}
