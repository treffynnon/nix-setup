#!/usr/bin/env bash

set -euo pipefail

OP_VAULT="Nix Config"
OP_ITEM="GitHub-PAT"
OP_FIELD="Token"
OP_REF="op://${OP_VAULT}/${OP_ITEM}/${OP_FIELD}"

function print_header() {
    echo "🐙 1Password GitHub CLI Setup & Verification"
    echo "============================================"
    echo
}

function verify_prerequisites() {
    echo "🔍 Checking prerequisites..."

    if ! command -v op >/dev/null 2>&1; then
        echo "❌ op not found in PATH — rebuild your Nix configuration first"
        return 1
    fi
    echo "✅ op available: $(op --version)"

    if ! command -v gh >/dev/null 2>&1; then
        echo "❌ gh not found in PATH — rebuild your Nix configuration first"
        return 1
    fi
    echo "✅ gh available: $(gh --version | head -1)"

    if [ ! -d "/Applications/1Password.app" ]; then
        echo "❌ 1Password.app not found in /Applications"
        return 1
    fi
    echo "✅ 1Password.app is installed"
    echo
}

function verify_nix_integration() {
    echo "🔍 Checking Nix-managed gh integration..."

    if grep -q "op plugin run -- gh" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo "✅ Fish gh wrapper configured via home-manager"
    else
        echo "⚠️  Fish gh wrapper not found in ~/.config/fish/config.fish"
        echo "   Rebuild with home-configs/github.nix imported in shared.nix"
    fi

    if [ "${OP_PLUGINS_SOURCED:-}" = "1" ]; then
        echo "✅ OP_PLUGINS_SOURCED=1 is set"
    else
        echo "⚠️  OP_PLUGINS_SOURCED is not set in this shell"
        echo "   Restart your terminal after rebuilding"
    fi

    if [ -L "$HOME/.config/gh/config.yml" ] || [ -f "$HOME/.config/gh/config.yml" ]; then
        echo "✅ gh config.yml present"
    else
        echo "⚠️  gh config.yml not found — rebuild your Nix configuration"
    fi
    echo
}

function verify_1password_item() {
    echo "🔍 Checking 1Password GitHub-PAT item..."

    if ! op read "$OP_REF" >/dev/null 2>&1; then
        echo "❌ Cannot read $OP_REF"
        echo "   Create a Secure Note titled \"GitHub-PAT\" in the \"Nix Config\" vault"
        echo "   with a field named \"Token\" containing your GitHub PAT"
        return 1
    fi

    local token_prefix
    token_prefix=$(op read "$OP_REF" | cut -c1-12)
    echo "✅ Token field readable (prefix: ${token_prefix}...)"

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $(op read "$OP_REF")" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/user")

    if [ "$http_code" = "200" ]; then
        echo "✅ Token is valid against the GitHub API"
    else
        echo "❌ Token failed GitHub API check (HTTP $http_code)"
        echo "   Create a new PAT at https://github.com/settings/tokens"
        echo "   Update the Token field on GitHub-PAT in 1Password"
        return 1
    fi
    echo
}

function verify_plugin_config() {
    echo "🔍 Checking 1Password gh shell plugin..."

    if [ ! -f "$HOME/.config/op/plugins.sh" ]; then
        echo "⚠️  plugins.sh not found — run: op plugin init gh"
        echo "   Select GitHub-PAT → map Token field → session or global scope"
        echo "   Do NOT manually source plugins.sh — Nix handles the gh wrapper"
        return 0
    fi
    echo "✅ plugins.sh exists"

    if op plugin inspect gh >/dev/null 2>&1; then
        echo "✅ gh shell plugin is configured:"
        op plugin inspect gh | sed 's/^/   /'
    else
        echo "⚠️  gh shell plugin not fully configured"
        echo "   Run interactively: op plugin init gh"
        echo "   Recommended scope: Prompt me for each new terminal session"
    fi
    echo
}

function check_keyring_credentials() {
    echo "🔍 Checking for stale macOS keychain gh credentials..."

    if security find-generic-password -s "gh:github.com" >/dev/null 2>&1; then
        echo "⚠️  Found gh credentials in macOS keychain (gho_ OAuth token)"
        echo "   These bypass 1Password and should be removed"
        echo "   Run: command gh auth logout --hostname github.com --user \$(gh api user -q .login 2>/dev/null || echo YOUR_USERNAME)"
        echo "   Or:  security delete-generic-password -s \"gh:github.com\""
    else
        echo "✅ No gh credentials found in macOS keychain"
    fi
    echo
}

function test_gh_auth() {
    echo "🔍 Testing gh authentication..."

    if ! type gh 2>/dev/null | grep -q "function\|is a function"; then
        echo "⚠️  gh is not wrapped in this shell — run: exec fish"
        echo "   Skipping live gh auth test"
        echo
        return 0
    fi

    local status_output
    set +e
    status_output=$(gh auth status 2>&1)
    local exit_code=$?
    set -e

    if echo "$status_output" | grep -q "Logged in to github.com"; then
        if echo "$status_output" | grep -q "keyring"; then
            echo "⚠️  gh is using macOS keychain instead of 1Password"
            echo "$status_output" | sed 's/^/   /'
        elif echo "$status_output" | grep -qi "GITHUB_TOKEN\|GH_TOKEN"; then
            echo "✅ gh authenticated via 1Password-injected token"
            echo "$status_output" | sed 's/^/   /'
        else
            echo "✅ gh auth status:"
            echo "$status_output" | sed 's/^/   /'
        fi
    elif echo "$status_output" | grep -q "invalid"; then
        echo "❌ gh token is invalid — update GitHub-PAT in 1Password"
        echo "$status_output" | sed 's/^/   /'
        return 1
    else
        echo "⚠️  gh auth status (exit $exit_code):"
        echo "$status_output" | sed 's/^/   /'
    fi
    echo
}

function print_setup_instructions() {
    echo "📋 One-time setup (interactive):"
    echo
    echo "   1. Create a classic PAT at https://github.com/settings/tokens"
    echo "      Scopes: repo, read:org, gist"
    echo "   2. Save it in 1Password → Nix Config → GitHub-PAT → Token field"
    echo "   3. Run: op plugin init gh"
    echo "      → Search in 1Password → GitHub-PAT"
    echo "      → Prompt me for each new terminal session (recommended)"
    echo "   4. Remove old keychain auth if present (see warnings above)"
    echo "   5. Reload shell: exec fish"
    echo "   6. Verify: gh auth status"
    echo
}

function print_security_tips() {
    echo "🔒 Security recommendations:"
    echo "   • Use \"Prompt me for each new terminal session\" in op plugin init"
    echo "   • Never run gh auth login — it stores tokens in macOS keychain"
    echo "   • Set 1Password auto-lock to a short interval"
    echo "   • Run op signout when finished with GitHub work"
    echo "   • Use classic PATs with minimal scopes; set an expiration date"
    echo "   • Git operations use SSH (1Password SSH agent), not HTTPS tokens"
    echo "   • See README.md → \"GitHub CLI via 1Password\" for full details"
    echo
}

function print_summary() {
    echo "🎉 Verification complete!"
    print_setup_instructions
    print_security_tips
}

function main() {
    print_header
    verify_prerequisites
    verify_nix_integration
    verify_1password_item || true
    verify_plugin_config
    check_keyring_credentials
    test_gh_auth || true
    print_summary
}

case "${1:-}" in
    "verify"|"check")
        print_header
        verify_prerequisites
        verify_nix_integration
        verify_1password_item || true
        verify_plugin_config
        check_keyring_credentials
        test_gh_auth || true
        ;;
    "setup")
        print_header
        print_setup_instructions
        print_security_tips
        ;;
    *)
        main
        ;;
esac
