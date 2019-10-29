{ lib, pkgs, ... }:

let
  inherit (lib) optional mkIf mkMerge;
  inherit (builtins) currentSystem;
  inherit (lib.systems.elaborate { system = currentSystem; }) isLinux isDarwin;
in

{
  imports = [ <home-manager/nix-darwin> ];
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = (with pkgs; [
    # utilities
    ## shell/terminal
    fish kitty any-nix-shell

    ## editors and paging
    bat vim jq imagemagick
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.Nix
        alanz.vscode-hie-server
        justusadam.language-haskell
        vscodevim.vim
        "skyapps.fish-vscode"
      ];
    })

    ## Network
    wget curl

    ## System
    coreutils which htop fzf

    ## compression
    unzip gzip

    # fonts
    nerdfonts

    # programming

    ## aws
    awscli

    ## postgresql
    pgcli

    ## vcs
    git

    ## haskell
    ghc cabal2nix cabal-install

    ## node
    nodejs
  ]) ++
  (with pkgs.vimPlugins; [
    base16-vim
    haskell-vim
    typescript-vim
    vim-fish
    vim-json
    vim-nix
  ]) ++
  (with pkgs.haskellPackages; [
    hlint
    hasktags
    hoogle
  ]);

  home-manager.users.simon = { pkgs, ... }: {
    home.packages = [ pkgs.haskellPackages.hoogle ];
    # programs.fish.enable = true;
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = false;
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    any-nix-shell fish --info-right | source
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 4;
  nix.buildCores = 4;
}

mkMerge [
  {
    environment.systemPackages =
      (with pkgs; [
        curl wget dnutils nmap telnet

        unzip zip

        file gnupg pciutils pv

        nix-prefetch-scripts
      ])
      ++
      (with pkgs.gitAndTools; [
        git git-fame
      ]);
  }

  (optionalAttrs isLinux {
    environment.systemPackages = with pkgs; [
      whois
    ];

    time.timeZone = "Australia/Brisbane";
    i18n = {
      consoleFont = "Lat2-Terminus16";
      defaultLocale = "en_AU.UTF-8";
      consoleUseXkbConfig = true;
    };
    services.xserver = {
      layout = "us";
      xkbOptions = "caps:escape";
    };

    system.stateVersion = "19.09";
  })

  (mkIf isDarwin {
    environment.systemPackages = with pkgs; [
      coreutils
    ];

    system.stateVersion = 4;
  })
]
