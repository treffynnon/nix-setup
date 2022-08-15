{ pkgs ? import (
    builtins.fetchTarball {
      name = "nix-master-25fb1e59d6";
      url = https://github.com/NixOS/nixpkgs/archive/25fb1e59d61b735f2e7c759c37feb449ce7eb8ae.tar.gz;
      sha256 = "0bxb2qlp9cf1g78pa2mqllp7d0s0n8ypr7m39q3rl76adlmkr8qa";
    }
  ) {}
}:
let
  version = "56b1d38d233eb0001bcae3b1403af827f0e542a3";
  appName = "LuaFormatter";
in
rec {
  LuaFormatter = with pkgs; stdenv.mkDerivation {
    name = "${appName}-${version}";
    version = "${version}";
    src = fetchgit {
      name = "${appName}";
      url = https://github.com/Koihik/LuaFormatter.git;
      rev = "${version}";
      sha256 = "1z59g9v82nmw4icx0kkv5b0vbia6a2s8gz5220gfgmg3yg8xhbsh";
      fetchSubmodules = true;
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
    meta = with lib; {
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
