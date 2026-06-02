# nix-setup

Personal Nix configuration supporting macOS (nix-darwin + Determinate), NixOS, and standalone Home Manager on Linux/WSL.

## Structure

```
~/.nixpkgs/
├── flake.nix                       # Entry point; auto-discovers hosts from hosts/
├── darwin-configuration.nix        # Shared macOS system config
├── nixos-configuration.nix         # Shared NixOS config
├── home-manager-configuration.nix  # Standalone home-manager config
├── shared-configuration.nix        # Cross-platform system packages and nix settings
│
├── lib/
│   ├── defaults.nix                # Centralised constants (user, nix settings)
│   ├── cli-packages.nix            # Shared CLI tool list (system + home-manager)
│   └── opnix-system.nix            # System-level 1Password secrets config
│
├── home-configs/
│   ├── shared.nix                  # Shared home-manager imports (all platforms)
│   ├── darwin.nix                  # macOS home-manager config
│   ├── linux.nix                   # Standalone home-manager (Linux)
│   ├── wsl.nix                     # Standalone home-manager (WSL)
│   └── ...                         # Per-app modules
│
├── hosts/
│   ├── <hostname>/darwin.nix       # macOS host-specific settings
│   ├── <hostname>/nixos.nix        # NixOS host-specific settings
│   └── <hostname>/meta.nix         # Optional: { system = "aarch64-linux"; }
│
├── overlays/                       # nixpkgs overlays
└── scripts/
    ├── setup.sh                    # Bootstrap script (installs Nix, applies config)
    ├── 1password-ssh.sh            # 1Password SSH agent setup/verify
    └── 1password-gh.sh             # 1Password GitHub CLI setup/verify
```

## Bootstrap

```bash
git clone <repo> ~/.nixpkgs
cd ~/.nixpkgs
./scripts/setup.sh
```

The script detects the platform, prompts for a hostname on macOS and NixOS, creates the host file if missing, installs Nix if needed, and runs the initial switch.

## Adding a macOS host

Create `hosts/<hostname>/darwin.nix`. Minimal example:

```nix
{
  networking.hostName = "mymac";
  system.stateVersion = 5;
  home-manager.users.simon.home.stateVersion = "24.05";
}
```

The flake auto-discovers any directory under `hosts/` that contains `darwin.nix`.

## Adding a NixOS host

Create `hosts/<hostname>/nixos.nix`:

```nix
{
  networking.hostName = "mybox";
  system.stateVersion = "24.05";
  # hardware-configuration.nix should be imported here for real installs
}
```

For non-x86_64 systems, also create `hosts/<hostname>/meta.nix`:

```nix
{ system = "aarch64-linux"; }
```

The flake auto-discovers any directory containing `nixos.nix` and reads the system from `meta.nix` if present (defaults to `x86_64-linux`).

## Rebuilding

```bash
# macOS
sudo darwin-rebuild switch --flake ~/.nixpkgs#$(hostname)

# NixOS
sudo nixos-rebuild switch --flake ~/.nixpkgs#$(hostname)

# Standalone home-manager (Linux/WSL)
home-manager switch --flake ~/.nixpkgs#simon@linux
home-manager switch --flake ~/.nixpkgs#simon@wsl
```

Or use the devshell scripts:

```bash
nix develop
rebuild          # auto-detects platform
darwin-rebuild-flake
nixos-rebuild-flake
home-manager-rebuild-flake
```

## 1Password integration

Git commit signing and GitHub CLI both run through 1Password. After first rebuild:

```bash
./scripts/1password-ssh.sh    # configure SSH agent
./scripts/1password-gh.sh     # configure gh CLI via op plugin
```

See the detailed docs in those scripts and in `home-configs/1password-ssh.nix`, `home-configs/github.nix`.

## Development

```bash
nix develop
format          # alejandra + lua-format
lint-nix        # statix
lint-deadnix    # deadnix
lint-lua        # luacheck
ci-format-nix   # alejandra --check (used by CI)
```

## Hammerspoon (macOS)

See [home-configs/hammerspoon/README.md](home-configs/hammerspoon/README.md) for Stream Deck automation, window management, and USB power management via uhubctl.

## Shell setup

After rebuild, switch your login shell:

```bash
chsh -s /run/current-system/sw/bin/fish
```

## Environment variables

Private vars go in `~/.env` (`KEY=VALUE` format). Both bash and fish load this on startup.
