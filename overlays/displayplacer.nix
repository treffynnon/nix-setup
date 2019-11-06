# self: super:
_: super:

rec {
  version = "1.2.0";
  appName = "displayplacer";
  displayplacer = with super; stdenv.mkDerivation {
    name = "${appName}-${version}";
    version = "${version}";
    src = fetchurl {
      name = "${appName}-${version}.zip";
      url = "https://github.com/jakehilborn/${appName}/archive/v${version}.zip";
      sha256 = "0a12c8r1ldqcblm2svviy9di95mi21r8zinq5w110d5144w0wkcl";
    };
    buildInputs = [ unzip ];
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    installPhase = ''
      mkdir --parents "$out"/bin
      cp "./${appName}" "$out"/bin
    '';
    meta = with stdenv.lib; {
      description = "macOS command line utility to configure multi-display resolutions and arrangements. Essentially XRandR for macOS.";
      homepage = https://github.com/jakehilborn/displayplacer;
      license = licenses.mit;
      platforms = platforms.darwin;
      maintainers = [
        {
          name = "Simon Holywell";
          email = "simon@holywell.com.au";
          github = "treffynnon";
        }
      ];
      repositories.git = https://github.com/jakehilborn/displayplacer;
    };
  };
}
