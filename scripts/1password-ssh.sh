#!/usr/bin/env bash

# 1Password SSH Agent Setup and Verification Script
# This script configures SSH to use 1Password SSH agent and verifies the setup

set -euo pipefail

SSH_CONFIG_FILE="$HOME/.ssh/config"
BACKUP_FILE="$SSH_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# 1Password SSH agent socket path for macOS
ONEPASSWORD_SOCKET_PATH="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

function print_header() {
    echo "🔑 1Password SSH Agent Setup & Verification"
    echo "==========================================="
    echo
}

function setup_ssh_config() {
    echo "🔧 Setting up SSH configuration..."

    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"

    # Backup existing SSH config if it exists
    if [[ -f "$SSH_CONFIG_FILE" ]]; then
        echo "📋 Backing up existing SSH config to: $BACKUP_FILE"
        cp "$SSH_CONFIG_FILE" "$BACKUP_FILE"
    fi

    # Check if 1Password SSH agent configuration already exists
    if grep -q "IdentityAgent.*1password" "$SSH_CONFIG_FILE" 2>/dev/null; then
        echo "✅ 1Password SSH agent configuration already exists in SSH config"
    else
        echo "➕ Adding 1Password SSH agent configuration to SSH config..."

        # Add 1Password SSH agent configuration to the beginning of the file
        {
            echo "# 1Password SSH Agent Configuration"
            echo "# Added by Nix configuration setup script"
            echo "Host *"
            echo "  IdentityAgent \"$ONEPASSWORD_SOCKET_PATH\""
            echo ""

            # Append existing config if it exists
            if [[ -f "$SSH_CONFIG_FILE" ]]; then
                cat "$SSH_CONFIG_FILE"
            fi
        } > "$SSH_CONFIG_FILE.tmp"

        mv "$SSH_CONFIG_FILE.tmp" "$SSH_CONFIG_FILE"
        echo "✅ 1Password SSH agent configuration added to SSH config"
    fi

    # Set appropriate permissions
    chmod 600 "$SSH_CONFIG_FILE"
    echo
}

function verify_1password() {
    echo "🔍 Verifying 1Password installation and configuration..."

    # Check if 1Password is installed
    if [ -d "/Applications/1Password.app" ]; then
        echo "✅ 1Password.app is installed"
    else
        echo "❌ 1Password.app not found in /Applications"
        return 1
    fi

    # Check if the SSH agent socket exists
    if [ -S "$ONEPASSWORD_SOCKET_PATH" ]; then
        echo "✅ 1Password SSH agent socket exists"
    else
        echo "❌ 1Password SSH agent socket not found"
        echo "   Make sure 1Password SSH agent is enabled in 1Password settings"
        return 1
    fi

    # Check SSH_AUTH_SOCK status
    echo "ℹ️  SSH_AUTH_SOCK is currently: ${SSH_AUTH_SOCK:-not set}"
    echo "   Note: 1Password SSH agent works via SSH config's IdentityAgent,"
    echo "   so SSH_AUTH_SOCK doesn't need to point to 1Password"
    echo
}

function test_ssh_agent() {
    echo "🔍 Testing SSH agent connectivity..."
    echo "   Testing direct connection to 1Password SSH agent..."

    if SSH_AUTH_SOCK="$ONEPASSWORD_SOCKET_PATH" ssh-add -l 2>/dev/null; then
        echo "✅ 1Password SSH agent is responding with keys"
    else
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            echo "⚠️  1Password SSH agent is running but no keys are loaded"
            echo "   Make sure you have SSH keys stored in your 1Password vaults"
        else
            echo "❌ 1Password SSH agent is not responding (exit code: $exit_code)"
            return 1
        fi
    fi
    echo
}

function check_agent_config() {
    echo "📝 Checking agent.toml configuration..."
    AGENT_CONFIG="$HOME/.config/1password/ssh/agent.toml"
    if [ -f "$AGENT_CONFIG" ]; then
        echo "✅ agent.toml exists: $AGENT_CONFIG"
        echo "   Configured vaults:"
        grep -E "vault = " "$AGENT_CONFIG" | sed 's/^/   - /' || echo "   - No vaults configured"
    else
        echo "❌ agent.toml not found: $AGENT_CONFIG"
        echo "   Run 'darwin-rebuild switch' to create it via Nix"
    fi
    echo
}

function test_github_ssh() {
    echo "🐙 Testing GitHub SSH connectivity..."

    # GitHub SSH returns exit code 1 even on successful auth, so we check the output message
    local github_output
    set +e  # Temporarily disable exit on error
    github_output=$(timeout 10 ssh -T git@github.com 2>&1)
    local ssh_exit_code=$?
    set -e  # Re-enable exit on error

    if echo "$github_output" | grep -q "successfully authenticated"; then
        echo "✅ GitHub SSH authentication successful (using SSH config)"
        # Extract username from the response if available
        if echo "$github_output" | grep -q "Hi "; then
            local username=$(echo "$github_output" | grep "Hi " | sed 's/Hi \([^!]*\).*/\1/')
            echo "   Authenticated as: $username"
        fi
    else
        echo "⚠️  GitHub SSH authentication failed or not configured"
        echo "   Make sure you have a GitHub SSH key in one of your 1Password vaults"
        echo "   and that SSH config is set up to use 1Password SSH agent"
        echo "   Response: $github_output"
        echo "   SSH exit code: $ssh_exit_code"
    fi
    echo
}

function print_summary() {
    echo "🎉 Setup and verification complete!"
    echo
    echo "📝 What was configured:"
    echo "   • SSH will use 1Password SSH agent for all hosts"
    echo "   • Your existing SSH config was preserved"
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "   • Backup created at: $BACKUP_FILE"
    fi
    echo
    echo "💡 Tips:"
    echo "   • Make sure 1Password app is running"
    echo "   • Enable SSH agent in 1Password settings"
    echo "   • Your SSH keys should be stored in 1Password"
    echo "   • Use 'ssh -T git@github.com' to test GitHub access"
}

function main() {
    print_header

    # Setup phase
    setup_ssh_config

    # Verification phase
    if ! verify_1password; then
        echo "❌ 1Password verification failed. Please install and configure 1Password first."
        exit 1
    fi

    test_ssh_agent
    check_agent_config
    test_github_ssh

    print_summary
}

# Handle command line arguments
case "${1:-}" in
    "verify"|"check")
        print_header
        verify_1password && test_ssh_agent && check_agent_config && test_github_ssh
        ;;
    "setup")
        print_header
        setup_ssh_config
        ;;
    *)
        main
        ;;
esac
