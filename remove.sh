#!/usr/bin/env bash
echo "removing nix from this machine"
sudo rm -rf /etc/nix /nix ~root/.nix-profile ~root/.nix-defexpr ~root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
# rm -rf /nix ~/.config/nixpkgs

if [ -f /etc/profile/nix.sh  ]; then
  sudo -f rm /etc/profile/nix.sh
fi

# delete the nix store
rm -rf /nix

# remove the multi-user install daemon
DAEMON_PATH="/Library/LaunchDaemons/org.nixos.nix-daemon.plist"
if [ -f "$DAEMON_PATH" ]; then
  sudo launchctl unload "$DAEMON_PATH"
  sudo rm "$DAEMON_PATH"
fi

# delete any left over config and cache links links
find -L ~/.config -type l -ipath "*nix*" -exec unlink {}
find -L ~/.cache -type l -ipath "*nix*" -exec unlink {}

