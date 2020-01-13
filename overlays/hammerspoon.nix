# self: super:
_: super:

rec {
  version = "0.9.77";
  appName = "Hammerspoon";
  Hammerspoon = with super; stdenv.mkDerivation {
    name = "${appName}-${version}";
    version = "${version}";
    src = fetchurl {
      name = "Hammerspoon.zip";
      url = "https://github.com/${appName}/hammerspoon/releases/download/${version}/${appName}-${version}.zip";
      sha256 = "1pjlip51knmzm83q2vjm33n5sshlbvmnwsc4hlabpsqsz0pz1ci4";
    };
    buildInputs = [ unzip ];
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appName}.app"
      cp -R . "$out/Applications/${appName}.app"
    '';
    meta = with stdenv.lib; {
      description = "Staggeringly powerful macOS desktop automation with Lua";
      homepage = https://www.hammerspoon.org/;
      license = licenses.mit;
      platforms = platforms.darwin;
      maintainers = [
        {
          name = "Simon Holywell";
          email = "simon@holywell.com.au";
          github = "treffynnon";
        }
      ];
      repositories.git = https://github.com/Hammerspoon/hammerspoon;
    };
  };
}
