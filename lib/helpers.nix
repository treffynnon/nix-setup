# Common helper functions for configuration
# Provides utilities for creating standardised user configurations and nix settings
{lib, ...}: let
  defaults = import ./defaults.nix;

  # Secrets management helper functions
  getSecret = secretName: defaultValue: let
    envVar = builtins.getEnv "NIX_${lib.toUpper secretName}";
  in
    if envVar != ""
    then envVar
    else defaultValue;

  # Safe secret handling - never expose actual values in error messages
  safeGetSecret = secretName: defaultValue: let
    secret = getSecret secretName defaultValue;
    isDefault = secret == defaultValue;
    isFromEnv = !isDefault;
  in {
    value = secret;
    inherit isFromEnv;
    # For logging/debugging - never expose actual secret
    source =
      if isFromEnv
      then "environment"
      else "default";
  };
in {
  # Inherit defaults for easy access
  inherit defaults;

  # Helper to create a standardised user configuration
  mkUser = {
    username ? defaults.user.username,
    shell ? "fish",
    extraGroups ? [],
    extraConfig ? {},
  }: {
    name = username;
    value =
      {
        inherit shell extraGroups;
        home =
          if builtins.elem builtins.currentSystem ["aarch64-darwin" "x86_64-darwin"]
          then "/Users/${username}"
          else "/home/${username}";
      }
      // extraConfig;
  };

  # Enhanced mkUser helper with secrets support
  mkUserWithSecrets = {
    username ? defaults.user.username,
    shell ? null,
    extraGroups ? [],
    extraConfig ? {},
  }: let
    secretsHelpers = (import ./helpers.nix {inherit lib;}).secrets;
    sshKey = secretsHelpers.getSshSigningKey;
  in {
    name = username;
    value =
      {
        home =
          if defaults.platform.isDarwin
          then "/Users/${username}"
          else "/home/${username}";
        inherit shell extraGroups;
        # Use secrets-aware SSH key
        openssh.authorisedKeys.keys = lib.optional (sshKey != null) sshKey;
      }
      // extraConfig;
  };

  # Helper to create standardised nix configuration
  mkNixConfig = {extraConfig ? {}}:
    {
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';
      settings = let
        inherit (defaults.nix) substituters trustedPublicKeys;
      in {
        inherit substituters;
        trusted-public-keys = trustedPublicKeys;
        experimental-features = ["nix-command" "flakes"];
      };
      gc = {
        automatic = true;
        options = defaults.nix.gcOptions;
      };
    }
    // extraConfig;

  # New: Automated dependency management helper
  mkAutomatedPackageManagement = {
    enableAutoUpdate ? true,
    enableAutoGC ? true,
    enableFlakeCheck ? true,
  }: {
    # Automatic package updates
    autoUpdate =
      if enableAutoUpdate
      then {
        enable = true;
        # Update weekly on Sunday at 2 AM
        dates = "weekly";
        randomizedDelaySec = "45min";
      }
      else {enable = false;};

    # Enhanced garbage collection
    gc =
      if enableAutoGC
      then {
        automatic = true;
        # Run garbage collection daily
        interval = "daily";
        options = "--delete-older-than 7d --delete-generations +5";
        randomizedDelaySec = "15min";
      }
      else defaults.nix.gcOptions;

    # Flake validation scheduling (for CI/CD)
    flakeCheck =
      if enableFlakeCheck
      then {
        enable = true;
        schedule = "0 2 * * 1"; # Weekly on Monday at 2 AM
      }
      else {enable = false;};
  };

  # New: Smart platform-aware package selection
  mkPlatformPackages = {
    basePackages ? [],
    darwinPackages ? [],
    linuxPackages ? [],
    aarch64Packages ? [],
  }: let
    isDarwin = builtins.elem builtins.currentSystem ["aarch64-darwin" "x86_64-darwin"];
    isLinux = builtins.elem builtins.currentSystem ["aarch64-linux" "x86_64-linux"];
    isAarch64 = builtins.elem builtins.currentSystem ["aarch64-darwin" "aarch64-linux"];
  in
    basePackages
    ++ (
      if isDarwin
      then darwinPackages
      else []
    )
    ++ (
      if isLinux
      then linuxPackages
      else []
    )
    ++ (
      if isAarch64
      then aarch64Packages
      else []
    );

  # New secrets management helpers
  secrets = {
    # Get SSH signing key with fallback
    getSshSigningKey = let
      secretInfo = safeGetSecret "ssh_signing_key" defaults.user.signingSshKey;
    in
      secretInfo.value;

    get = secretName: defaultValue: (safeGetSecret secretName defaultValue).value;

    # Check if secret is from environment (for validation)
    isFromEnv = secretName: defaultValue: (safeGetSecret secretName defaultValue).isFromEnv;
  };

  # Enhanced git configuration with secrets
  mkGitConfigWithSecrets = extraConfig: let
    secretsHelpers = (import ./helpers.nix {inherit lib;}).secrets;
    sshKey = secretsHelpers.getSshSigningKey;
  in {
    enable = true;
    userName = defaults.user.fullName;
    userEmail = defaults.user.email;

    # Only set signing key if we have one from environment
    extraConfig =
      {
        user.signingkey = lib.mkIf (secretsHelpers.isFromEnv "ssh_signing_key" defaults.user.signingSshKey) sshKey;
        commit.gpgsign = lib.mkIf (sshKey != null) true;
        gpg.format = lib.mkIf (sshKey != null) "ssh";
      }
      // extraConfig;
  };
}
