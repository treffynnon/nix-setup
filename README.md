# Modernized Nix Configuration

A comprehensive, cross-platform Nix configuration supporting Darwin (macOS), NixOS (Linux), and standalone Home Manager with integrated 1Password secrets management.

## 🏗️ Architecture Overview

This configuration has been modernized from a legacy, duplicated setup to a clean, maintainable architecture with the following key features:

- **🔄 Zero Configuration Duplication** - Unified shared configurations across platforms
- **🔐 Secure Secrets Management** - 1Password integration via opnix
- **🎯 Smart Platform Detection** - Automatic adaptation to current system architecture
- **⚡ Comprehensive Automation** - CI/CD validation and automated maintenance
- **📦 Centralised Configuration** - Single source of truth for all settings

## 📁 Project Structure

```
~/.nixpkgs/
├── flake.nix                       # 🚀 Main entry point with smart system detection
├── flake.lock                      # 📦 Locked dependencies (includes opnix)
│
├── shared-configuration.nix        # 🌍 Cross-platform shared configuration
├── darwin-configuration.nix        # 🍎 macOS-specific configuration
├── nixos-configuration.nix         # 🐧 Linux/NixOS configuration
├── home-manager-configuration.nix  # 🏠 Standalone home-manager config
│
├── lib/                            # 📚 Core library modules
│   ├── defaults.nix                # ⚙️  Centralised constants and user data
│   ├── helpers.nix                 # 🛠️  Helper functions for configurations
│   ├── platform.nix                # 🎯 Platform detection utilities
│   ├── secrets.nix                 # 🔐 Secret references for 1Password
│   └── opnix-system.nix            # 🔑 System-level opnix configuration
│
├── home-configs/                   # 🏠 Home Manager modules
│   ├── shared.nix                  # 🌍 Unified home-manager configuration
│   ├── opnix.nix                   # 🔐 1Password secrets integration
│   ├── git.nix                     # 📝 Git with SSH signing via 1Password
│   ├── fish.nix                    # 🐟 Fish shell configuration
│   ├── hammerspoon/                # 🔨 Stream Deck automation (macOS)
│   │   ├── uhubctl.lua             # 🔌 USB power management
│   │   └── Spoons/ElgatoStreamDeck.spoon/ # 🎮 Stream Deck sleep/wake automation
│   └── ... (other app configs)
│
├── hosts/                          # 🖥️  Host-specific configurations
│   ├── pademelon/configuration.nix # 🦘 Host-specific settings & stateVersion
│   ├── bilby/configuration.nix     # 🐨 (per-host state management)
│   └── ... (other hosts)
│
├── .github/workflows/ci.yml        # 🚀 Multi-platform CI/CD validation
└── overlays/                       # 📦 Package customisations
```

## 🚀 Quick Start

### Automated Setup (Recommended)

For the best experience, use the optimized setup script:

```bash
git clone <repository-url> ~/.nixpkgs
cd ~/.nixpkgs
./scripts/setup.sh
```

#### 🎯 Setup Script Features

The modernized `setup.sh` includes several optimizations:

- **🔍 Pre-flight Validation** - Checks configuration validity before starting
- **📊 Progress Tracking** - Clear step indicators (1/7, 2/7, etc.)
- **🛡️ Error Recovery** - Automatic cleanup on failure with IPv6 restoration
- **🔄 Smart Network Handling** - Temporary IPv6 disable/re-enable for compatibility
- **✅ Post-setup Validation** - Verifies configuration after installation
- **🖥️ Host-specific Config** - Automatically creates host configurations with auto-detected state versions
- **🎯 Smart State Detection** - Detects appropriate system and Home Manager state versions from:
  - Existing system installations (`nixos-version`, `darwin-version`)
  - Current nixpkgs version (`nix eval nixpkgs#lib.version`)
  - Reference configurations from other hosts
- **🐚 Shell Integration** - Switches to Nix-managed Fish/Bash shells
- **🔑 1Password Integration** - Sets up SSH agent with 1Password

### Manual Setup (Advanced Users)

#### Prerequisites

1. **Install Nix** with flakes enabled:

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Clone this repository**:
   ```bash
   git clone <repository-url> ~/.nixpkgs
   cd ~/.nixpkgs
   ```

### Platform-Specific Setup

#### 🍎 macOS (Darwin)

```bash
# Install nix-darwin
nix run nix-darwin -- switch --flake ~/.nixpkgs

# For host-specific configuration (recommended)
sudo darwin-rebuild switch --flake ~/.nixpkgs#$(hostname)

# Or use default configuration
sudo darwin-rebuild switch --flake ~/.nixpkgs#default
```

#### 🐧 NixOS (Linux)

```bash
# For host-specific configuration
sudo nixos-rebuild switch --flake ~/.nixpkgs#$(hostname)

# Or use default configuration
sudo nixos-rebuild switch --flake ~/.nixpkgs#default
```

#### 🏠 Home Manager (Standalone)

```bash
# Install home-manager
nix run home-manager/master -- switch --flake ~/.nixpkgs#simon@$(hostname)

# Or use default configuration
nix run home-manager/master -- switch --flake ~/.nixpkgs#simon@default
```

## 🔐 1Password Secrets Management

This configuration uses **opnix** for secure integration with 1Password. Here's how to set it up:

### Manual Setup Steps

#### 1. 1Password CLI Installation

The 1Password CLI is automatically installed via Nix as part of this configuration. You don't need to install it manually.

**Note:** The CLI is included in the shared configuration (`shared-configuration.nix`) and will be available after your first build.

#### 2. Configure 1Password Items

Create these items in your 1Password vault named "Nix Config":

**SSH Signing Key for Git:**

- Item Type: SSH Key
- Title: "GitHub Commit Signing Key"
- Public Key field: Your SSH public key (e.g., `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...`)
- Tags: nix, ssh, signing

**GitHub Personal Access Token:**

- Item Type: Password/Login
- Title: "GitHub-PAT"
- Password/Credential field: Your GitHub token
- Tags: nix, github, automation

#### 3. Test 1Password CLI Access

After building your configuration, the 1Password CLI will be available in your PATH:

```fish
# Sign in to 1Password CLI
op signin

# Test secret retrieval
op read "op://Nix Config/GitHub Commit Signing Key/public key"
op read "op://Nix Config/GitHub-PAT/password"
```

#### 4. System-Level opnix Setup

The configuration automatically handles:

- Creating `onepassword-secrets` group
- Adding your user to the group
- Setting proper permissions on `/etc/opnix-token`

#### 5. Verify Integration

```bash
# Rebuild your configuration
nix flake check  # Validate configuration

# On macOS
sudo darwin-rebuild switch --flake ~/.nixpkgs#$(hostname)

# On NixOS
sudo nixos-rebuild switch --flake ~/.nixpkgs#$(hostname)
```

### Troubleshooting 1Password Integration

If secrets aren't working:

1. **Verify 1Password CLI is available (it should be installed automatically):**

   ```fish
   which op
   op --version
   ```

2. **Check 1Password CLI connection:**

   ```fish
   op account list
   op signin
   ```

3. **Verify secret references:**

   ```fish
   op read "op://Nix Config/GitHub Commit Signing Key/public key"
   ```

4. **Check group membership:**

   ```fish
   groups | grep onepassword-secrets
   ```

5. **Verify token permissions:**

   ```fish
   ls -la /etc/opnix-token
   # Should show: -rw-r----- 1 root onepassword-secrets
   ```

6. **Fallback to environment variables:**
   ```fish
   set -gx NIX_SSH_SIGNING_KEY "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."
   set -gx NIX_GITHUB_TOKEN "ghp_..."
   ```

## 🎯 Available Configurations

### Darwin (macOS) Configurations

- `darwinConfigurations.default` - Auto-detects current architecture (falls back to aarch64-darwin)
- `darwinConfigurations.bilby` - Host-specific configuration
- `darwinConfigurations.pademelon` - Host-specific configuration
- `darwinConfigurations.platypus` - Host-specific configuration
- `darwinConfigurations.thylacine` - Host-specific configuration

### NixOS (Linux) Configurations

- `nixosConfigurations.default` - x86_64-linux default
- `nixosConfigurations.default-arm64` - aarch64-linux support
- `nixosConfigurations.nixos-vm` - VM configuration

### Home Manager Configurations

- `homeConfigurations."simon@default"` - Default Linux configuration
- `homeConfigurations."simon@default-arm64"` - ARM64 Linux configuration
- `homeConfigurations."simon@wsl"` - WSL-specific configuration
- `homeConfigurations."simon@linux"` - Generic Linux configuration

## 🔧 Development & Maintenance

### Validation & Testing

```bash
# Validate entire flake
nix flake check

# Test specific configuration
nix build .#darwinConfigurations.default.system --dry-run
nix build .#nixosConfigurations.default.config.system.build.toplevel --dry-run

# Check formatting
nix develop --command alejandra --check .

# Run linting
nix develop --command statix check .
```

### Updating Dependencies

```bash
# Update flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Adding New Hosts

1. Create host-specific configuration:

   ```bash
   mkdir -p hosts/newhostname
   ```

2. Create `hosts/newhostname/configuration.nix`:

   ```nix
   {
     networking.hostName = "newhostname";
     system.stateVersion = 5; # Set based on installation date
     home-manager.users.simon.home.stateVersion = "24.05";

     # Host-specific overrides here
   }
   ```

3. **Add the new host to `flake.nix`** in the `darwinConfigurations` section:
   ```nix
   newhostname = darwin.lib.darwinSystem {
     system = currentSystem;
     specialArgs = { inherit home-manager opnix; };
     modules = [
       darwinConfiguration
       ./hosts/newhostname/configuration.nix
     ];
   };
   ```

## 📱 Enhanced Features

### Stream Deck Automation (macOS)

- **Automatic USB power management** during sleep/wake cycles
- **uhubctl integration** for precise USB port control
- **Elgato Stream Deck support** with auto-detection

### Comprehensive CI/CD

- **Multi-platform testing** (Ubuntu, macOS)
- **Multiple Nix versions** validation
- **Security scanning** for hardcoded secrets
- **Automated formatting** and linting

### Smart Platform Detection

- **Automatic architecture detection** (aarch64-darwin, x86_64-darwin, etc.)
- **Cross-platform package selection**
- **Platform-specific optimisations**

## 🔄 Migration from Legacy Configuration

This configuration modernizes from a legacy setup with the following improvements:

1. **Eliminated Massive Duplication** - Reduced from triple-duplicated configurations to unified shared configs
2. **Centralised State Management** - Moved from centralised to per-host stateVersion management
3. **Enhanced Security** - Integrated 1Password secrets management
4. **Improved Maintainability** - Single source of truth for all configuration data
5. **Better Platform Support** - Smart detection and cross-platform compatibility

## 📚 Key Concepts

### State Version Management

- **Per-host configuration** in `hosts/*/configuration.nix`
- **Never update stateVersion** unless you understand migration implications
- **Set stateVersion** based on when you first installed each system

### Centralised Configuration

- **`lib/defaults.nix`** - Single source of truth for user data
- **Platform helpers** - Smart detection and cross-platform utilities
- **Unified modules** - Shared configurations across platforms

### Secrets Management

- **opnix integration** - Secure 1Password CLI integration
- **Environment variable fallbacks** - Works without 1Password
- **Proper group management** - Secure permissions and access control

## 🆘 Troubleshooting

### Setup Script Issues

1. **Setup script fails at validation step:**

   ```bash
   # Check configuration syntax manually
   nix flake check --show-trace ~/.nixpkgs

   # Run validation separately
   cd ~/.nixpkgs && nix flake check --no-build
   ```

2. **Xcode Command Line Tools installation hangs:**

   - Cancel the installation (`Ctrl+C`)
   - Try manual installation: `xcode-select --install`
   - Rerun setup script after tools are installed

3. **IPv6 issues causing network failures:**

   ```bash
   # Re-enable IPv6 manually if script fails
   sudo networksetup -setv6automatic Wi-Fi
   sudo networksetup -setv6automatic Ethernet
   ```

4. **Host configuration creation fails:**

   ```bash
   # Check permissions in hosts directory
   ls -la ~/.nixpkgs/hosts/

   # Create directory manually if needed
   mkdir -p ~/.nixpkgs/hosts/$(hostname)
   ```

5. **Darwin rebuild fails with "not found" errors:**

   ```bash
   # Source Nix environment manually
   source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

   # Check if nix-darwin is available
   command -v darwin-rebuild
   ```

### Common Issues

1. **Build failures after updates:**

   ```bash
   nix flake check --show-trace
   ```

2. **Permission issues with secrets:**

   ```bash
   sudo chgrp onepassword-secrets /etc/opnix-token
   sudo chmod 640 /etc/opnix-token
   ```

3. **Platform detection issues:**

   ```bash
   nix eval --expr 'builtins.currentSystem'
   ```

4. **Home Manager conflicts:**
   ```bash
   home-manager switch --flake ~/.nixpkgs#simon@$(hostname) --show-trace
   ```

## 🔨 Manual Setup Steps

### Setting up 1Password SSH Agent

The Nix configuration automatically creates the 1Password SSH agent configuration file (`~/.config/1password/ssh/agent.toml`), but to keep your SSH host configurations private, you need to manually configure SSH to use the 1Password agent.

#### Automated Setup (Recommended)

Run the consolidated setup and verification script:

```bash
./scripts/1password-ssh.sh
```

This script will:

- **Setup Phase:**

  - Backup your existing SSH config (with timestamp)
  - Add 1Password SSH agent configuration to `~/.ssh/config`
  - Preserve your existing host configurations
  - Set appropriate permissions (600) on SSH config

- **Verification Phase:**
  - Verify 1Password app installation
  - Check SSH agent socket availability
  - Test SSH agent connectivity and list available keys
  - Validate `agent.toml` configuration and configured vaults
  - Test GitHub SSH authentication with username detection

You can also run specific operations:

```bash
./scripts/1password-ssh.sh setup   # Setup SSH config only
./scripts/1password-ssh.sh verify  # Verification tests only (alias: check)
```

The script provides detailed status indicators:

- ✅ Success indicators for working components
- ⚠️ Warnings for non-critical issues
- ❌ Error indicators for problems requiring attention
- ℹ️ Informational messages with helpful context

#### Manual Setup

If you prefer to configure SSH manually, add this to your `~/.ssh/config` file:

```ssh-config
# 1Password SSH Agent Configuration
# Added by Nix configuration setup script
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Or configure it for specific hosts only:

```ssh-config
Host github.com
  HostName github.com
  User git
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

#### Verification

After setup, the script automatically verifies the configuration, but you can also test manually:

```fish
# Test SSH connection to GitHub (uses 1Password SSH agent automatically)
ssh -T git@github.com

# List available SSH keys from 1Password
SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ssh-add -l
```

**Note:** You don't need to set `SSH_AUTH_SOCK` in your shell environment. The SSH config's `IdentityAgent` directive tells SSH to use 1Password directly for each connection.

#### Troubleshooting 1Password SSH

If the automated script reports issues, here are common solutions:

**1Password App Not Found:**

```fish
# Verify 1Password is installed
ls -la "/Applications/1Password.app"
```

**SSH Agent Socket Missing:**

```fish
# Check if 1Password SSH agent is enabled
# Open 1Password → Settings → Developer → Use the SSH agent
ls -la "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

**No SSH Keys Found:**

```fish
# Verify SSH keys are stored in 1Password vaults
# Keys should be in one of the vaults configured in agent.toml
./scripts/1password-ssh.sh verify  # Shows configured vaults
```

**GitHub Authentication Failed:**

```fish
# Test GitHub SSH manually with verbose output
ssh -vT git@github.com
# Should show: "Hi username! You've successfully authenticated"
```

**agent.toml Missing:**

```fish
# Rebuild Nix configuration to create agent.toml
darwin-rebuild switch --flake ~/.nixpkgs#(hostname)
```

**Restore SSH Config:**

```fish
# If setup went wrong, restore from backup
# Backups are created with timestamps, e.g.:
cp ~/.ssh/config.backup.20250619_160056 ~/.ssh/config
```

### Setting up Hammerspoon

Install Hammerspoon from <https://www.hammerspoon.org/>

Hammerspoon provides:

- Window management via the keyboard
- `Caps lock` as `Esc` when tapped and `Ctrl` when held
- Stream Deck automation and USB power management

Run Hammerspoon (use Spotlight with `Command` + `Space`) - note that it can take some time to start initially - be patient - and configure it to:

- Run at login
- Enable Accessibility
- (optionally) untick "Show dock icon"

The configuration is in `./home-configs/hammerspoon.nix` and `./home-configs/hammerspoon/`.

**📖 For detailed documentation of all Hammerspoon features, Spoons, and configuration options, see: [home-configs/hammerspoon/README.md](home-configs/hammerspoon/README.md)**

### Shell Setup

For bash completions to work properly the system must use the nix supplied version of bash as the macOS version is ancient:

```bash
chsh -s /run/current-system/sw/bin/bash
```

If you want to use Fish shell then:

```bash
chsh -s /run/current-system/sw/bin/fish
```

See <https://discourse.nixos.org/t/using-nix-to-install-login-shell-on-non-nixos-platform/2807/3>

### GPG Setup

For the SSH agent and git commits to work the GPG signing key must be present. If you have already got one then import it:

```bash
gpg --import /path/to/your.key
```

Otherwise you can create one using this comprehensive guide - <https://blog.tinned-software.net/create-gnupg-key-with-sub-keys-to-sign-encrypt-authenticate/>

### Environment Variables

Private or secret environment vars you don't want to commit into a repository can be stored in `~/.env` with the following format:

```
MY_VAR=MY_VALUE
```

**Note:** The `.env` file support is automatically configured for both bash and fish shells and will load environment variables on shell startup:

- **Bash**: Uses `source ~/.env` in the shell initialisation
- **Fish**: Uses the `load_dotenv` function to parse and set variables

## 💻 Development Environment Management

### Direnv Integration

This project uses `nix-direnv` for development environments. For new projects:

Put a `.envrc` file inside your project with:

```bash
use flake
```

And create a `flake.nix` for your development shell:

```nix
{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            python3
            # Add your development dependencies here
          ];
        };
      });
}
```

### Formatting and Linting

This project uses:

- [alejandra](https://github.com/kamadorueda/alejandra) - Nix formatter
- [statix](https://github.com/nerdypepper/statix) - Nix linter
- [LuaFormatter](https://github.com/Koihik/LuaFormatter) - Lua formatter
- [luacheck](https://github.com/mpeterv/luacheck) - Lua linter

To easily run the formatters locally you can use the supplied development shell:

```bash
nix develop
alejandra --check .
statix check .
```

## 🔗 Useful Links

### Nix Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/unstable/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Zero to Nix](https://zero-to-nix.com) - Great beginner guide
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix

### Flakes

- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)
- [Tweag Flakes Blog](https://www.tweag.io/blog/2020-05-25-flakes/)
- [NixOS and Flakes Book](https://nixos-and-flakes.thiscute.world)
- [Determinate Systems Flakes Guide](https://determinate.systems/posts/nix-github-actions)

### Configuration Examples

- [Dustin Lyons Config](https://github.com/dustinlyons/nixos-config) - Comprehensive example
- [jnsgruk's NixOS Config](https://github.com/jnsgruk/nixos-config) - Sophisticated desktop configurations and theme management ⚠️ _Archived (owner moved to Ubuntu)_
- [kaleocheng's Nix Dots](https://github.com/kaleocheng/nix-dots) - Multi-platform features/flavours organisation
- [Daniel's Home](https://github.com/danieldk/nix-home/tree/master/cfg) - Clean config examples
- [Jomik's Dotfiles](https://github.com/Jomik/dotfiles/tree/master/.config/nixpkgs) - Good structure
- [jwiegley's config](https://github.com/jwiegley/nix-config/blob/master/overlays/30-apps.nix) - Advanced overlays
- [Rycee's post](https://rycee.net/posts/2017-07-02-manage-your-home-with-nix.html) - Home Manager intro

### Development

- [Nix Development Workflow](https://medium.com/@ejpcmac/about-using-nix-in-my-development-workflow-12422a1f2f4c)
- [Building C/C++ with Nix](https://gist.github.com/CMCDragonkai/41593d6d20a5f7c01b2e67a221aa0330)
- [Direnv Setup Guide](https://github.com/direnv/direnv#setup)
- [Nix Helpers](http://chriswarbo.net/git/nix-helpers/git/branches/master/index.html)
- [Useful Nix Hacks](http://chriswarbo.net/projects/nixos/useful_hacks.html)

### macOS Specific

- [macOS Settings Values](https://gist.github.com/smgt/3227665) - List of macOS defaults
- [Starter macOS Scripts](https://github.com/joeyhoer/starter/tree/master/system)
- [Nix Darwin Documentation](https://daiderd.com/nix-darwin/) - Official nix-darwin documentation
- [Homebrew to Nix Migration](https://www.softinio.com/post/moving-from-homebrew-to-nix-package-manager/)

### Monitor Management (macOS)

- [Display Position Issues](https://apple.stackexchange.com/questions/42835/primary-display-randomly-changes/296905#296905)
- [OSX Display Positioner](https://github.com/lucasvickers/osx-display-positioner)
- [Multi-Monitor Setup](https://superuser.com/questions/1105308/mac-3-monitor-setup-my-desktop-set-keep-switching-places-between-monitors/1220526)
- [Spaces Management](https://superuser.com/questions/917958/how-can-i-stop-osx-from-combining-spaces-when-i-unplug-a-monitor)

## 🗑️ Uninstalling

You can reverse the setup process by running the remove script:

```bash
./scripts/remove.sh
```

## 📄 Licence

This configuration is provided as-is for educational and personal use.

---

**🎉 Configuration complete!** You now have a modern, maintainable Nix setup with secure secrets management and cross-platform support.
