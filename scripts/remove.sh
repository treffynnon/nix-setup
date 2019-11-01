#!/bin/bash
# this is to ensure that we're not running inside a nix supplied bash shell

# Ensure script is not being run with root privileges
if [ $EUID -eq 0 ]; then
  echo "Please don't run this script with root privileges!"
  exit 1
fi

SUDO_ON=$(sudo -n command &>/dev/null; echo $?)
if [ $SUDO_ON -gt 0 ]; then
  echo "Some of the operations must be run as admin so please enter your admin password: "
  sudo -v
fi

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

function fix_dirty_etc_shells () {
  if [ -L /etc/shells -a ! -e /etc/shells ]; then
    echo "  * /etc/shells has been detected as a broken symlink"
    sudo unlink /etc/shells
  elif [ ! -L /etc/shells -a ! -f /etc/shells -a -e /etc/shells ]; then
    echo "  * /etc/shells is no longer a valid file"
    sudo rm -f /etc/shells
  fi
  if [ ! -e /etc/shells ]; then
    if [ -f /etc/shells.bak ]; then
      echo "  * Restoring /etc/shells from /etc/shells.bak"
      sudo mv /etc/shells.bak /etc/shells
    else
      echo "  * Restoring the default mac osx /etc/shells file"
      sudo tee /etc/shells <<EOF > /dev/null
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.
/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
EOF
    fi
    echo "  * Finished repairing /etc/shells"
  fi
}

echo " "
echo "Checking /etc/shells"
fix_dirty_etc_shells

if [[ "$SHELL" == "/run"* ]]; then
  echo " "
  echo "+==============================================================+"
  echo "|  Your current default shell is controlled by nix so we must  |"
  echo "|  change it. You will be asked for your user password - this  |"
  echo "|  may not be the same as sudo.                                |"
  echo "+==============================================================+"
  echo " "
  chsh -s /bin/bash
  echo " "
  echo "+==============================================================+"
  echo "|                          !WARNING!                           |"
  echo "|  You need to logout and back in again before running the     |"
  echo "|  next step. You could skip this step, but you'll end up in   |"
  echo "|  a funny state with your shell. You won't be able to start   |"
  echo "|  a new terminal!                                             |"
  echo "+==============================================================+"
  echo " "
  exit 1
fi

echo " "

echo "Start removing nix from this machine:"
echo "  * Deleting global nix configs and profiles"
sudo rm -rf /etc/nix /nix ~root/.nix-profile ~root/.nix-defexpr ~root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

if [ -f /etc/profile/nix.sh  ]; then
  echo "  * Deleting the default nix shell profile setup script"
  sudo rm -f /etc/profile/nix.sh
fi

echo "  * Deleting the nix store"
sudo rm -rf /nix

if [ -e "$HOME/.config/nixpkgs" ]; then
  echo "  * Deleting user's nix.conf file"
  sudo rm -rf "$HOME/.config/nixpkgs"
fi

DAEMON_PATH="/Library/LaunchDaemons/org.nixos.nix-daemon.plist"
if [ -f "$DAEMON_PATH" ]; then
  echo "  * Stopping the multi-user nix daemon"
  sudo launchctl unload "$DAEMON_PATH"
  echo "  * Deleting the multi-user nix daemon"
  sudo rm "$DAEMON_PATH"
fi
echo "  * Finished removing nix files"
echo " "

# ensure /etc/shells is still OK
echo "Resetting /etc/shells after store deletion"
fix_dirty_etc_shells

# delete any left over config and cache links links
echo "Removing any left-over (broken) symlinks"
./broken_symlinks echo ~/.config '^\/(nix|run\/current-system)'
./broken_symlinks echo ~/.cache '^\/(nix|run\/current-system)'
./broken_symlinks echo /etc '^\/(nix|run\/current-system)'

echo " "
echo "Finished!"
