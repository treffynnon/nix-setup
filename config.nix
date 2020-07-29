{ pkgs }:
let
  inherit (pkgs) lib buildEnv;
  inherit (lib) imap0 concatMap filter getName;

  packages =
    (import ./profiles/simon.nix { inherit pkgs lib; }) //
    (import ./profiles/default.nix { inherit pkgs lib; });
  packageDerivatives =
    (concatMap (x: x.environment.systemPackages)
      # packages = { _type = "merge"; contents = [ ... ]; }
      (filter (builtins.hasAttr "environment") packages.contents) # [ { ... } ]
    );

# https://nixos.org/nixpkgs/manual/#sec-getting-documentation
in {
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {
    myProfile = writeText "my-profile" ''
      export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/sbin:/bin:/usr/sbin:/usr/bin
      export MANPATH=$HOME/.nix-profile/share/man:/nix/var/nix/profiles/default/share/man:/usr/share/man
    '';
    userConfiguration = lib.lowPrio buildEnv {
      name = "user-configuration";
      ignoreCollisions = true;
      paths = (
        with pkgs; [
          (runCommand "profile" {} ''
            mkdir -p $out/etc/profile.d
            cp ${myProfile} $out/etc/profile.d/my-profile.sh
          '')

          # any custom packages can go here
        ] ++ packageDerivatives
      );
      pathsToLink = [ "/share/man" "/share/doc" "/bin" "/etc" ];
      extraOutputsToInstall = [ "man" "doc" ];
    };
  };
}


