{ pkgs ? import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
    }
  ) {}
}:
let
  version = "afc280eaaa743b4d01e65cfa097dcb9b213b1949";
  appName = "LuaFormatter";
in
rec {
  LuaFormatter = with pkgs; stdenv.mkDerivation {
    name = "${appName}-${version}";
    version = "${version}";
    src = fetchurl {
      name = "${appName}.zip";
      url = "https://github.com/Koihik/${appName}/archive/${version}.zip";
      sha256 = "0kghqk0a9rlmhzk1pqqrr1zz6895ijzgx02nz56d5nc9vknvd1sr";
    };
    buildInputs = [ unzip ];
    nativeBuildInputs = [ cmake ];
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildPhase = ''
      cmake .
      make
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp lua-format $out/bin
    '';
    meta = with stdenv.lib; {
      description = "Code formatter for Lua";
      homepage = https://github.com/Koihik/LuaFormatter;
      license = licenses.asl20;
      # platforms = [platforms.darwin platforms.linux];
      maintainers = [
        {
          name = "Simon Holywell";
          email = "simon@holywell.com.au";
          github = "treffynnon";
        }
      ];
      repositories.git = https://github.com/Koihik/LuaFormatter;
    };
  };
}
