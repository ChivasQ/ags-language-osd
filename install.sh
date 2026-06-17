#!/bin/bash

# Color variables for console output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Starting AGS OSD deployment...${NC}"

#  Check for the original binary
if [ ! -f "/usr/local/bin/ags-core" ]; then
    if [ -f "/usr/local/bin/ags" ]; then
        echo -e "${GREEN}[*] Isolating the original binary...${NC}"
        sudo mv /usr/local/bin/ags /usr/local/bin/ags-core
    else
        echo -e "${RED}[!] AGS is not installed in /usr/local/bin. Aborting.${NC}"
        exit 1
    fi
fi

# Install the patched wrapper
echo -e "${GREEN}[*] Installing GJS system wrapper...${NC}"
sudo cp ./system-patch/ags-wrapper /usr/local/bin/ags
sudo chmod +x /usr/local/bin/ags

# Create symlinks (if the repository is cloned to a different directory)
CONFIG_DIR="$HOME/.config/ags"
CURRENT_DIR="$(pwd)"

if [ "$CURRENT_DIR" != "$CONFIG_DIR" ]; then
    echo -e "${GREEN}[*] Creating configuration symlinks...${NC}"
    mkdir -p ~/.config
    ln -sfn "$CURRENT_DIR" "$CONFIG_DIR"
fi

echo -e "${GREEN}[+] Installation complete. Run: ags -c ~/.config/ags/config.js${NC}"
