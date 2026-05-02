#!/bin/bash

clear
echo "=== PIXEL LABEL TOOL INSTALLER ==="
echo "Installing required packages..."

sudo apt update
sudo apt install -y imagemagick dialog feh

echo ""
echo "Done."
echo "You can now run: pixel-label-maker"
sleep 2
