final: prev: {
  vscode = prev.vscode.overrideAttrs (oldAttrs: {
    runtimeDependencies = prev.lib.optionals prev.stdenv.isLinux [
      prev.systemd
      prev.fontconfig.lib
    ];
  });
}
