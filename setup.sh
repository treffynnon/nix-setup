#! /usr/bin/env bash

# Nix
curl https://nixos.org/nix/install | sh

# nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# home-manager
nix-channel --add https://github.com/rycee/home-manager/archive/release-19.03.tar.gz home-manager
nix-channel --update

sudo mv /etc/shells /etc/shells.bak
sudo mv /etc/zprofile /etc/zprofile.local
sudo mv /etc/zshrc /etc/zshrc.local

darwin-rebuild switch
