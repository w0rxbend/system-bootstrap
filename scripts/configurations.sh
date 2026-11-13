#!/usr/bin/env zsh

echo "Init base git configuration"
git config --global user.email "balyszyn@gmail.com"
git config --global user.name "w0rxbend"
git config --global pull.rebase true
git config --global init.defaultBranch main
git config --global core.autocrlf input

echo "Configuring Time..."
if [ -d /run/systemd/system ]; then
    sudo timedatectl set-local-rtc 0
    sudo timedatectl set-ntp true
fi
