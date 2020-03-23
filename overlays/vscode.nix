_: super:

rec {
  vscode = super.vscode.overrideAttrs (
    _: rec {
      runtimeDependencies = super.lib.optional (super.stdenv.isLinux) [ super.systemd.lib super.fontconfig.lib ];
    }
  );
}
