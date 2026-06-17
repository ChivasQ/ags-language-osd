#!/bin/bash

# Color variables for console output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[*] Starting AGS OSD installation...${NC}"

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

# Permissions for startup script
echo -e "${GREEN}[*] Securing execution permissions...${NC}"
chmod +x "$CONFIG_DIR/startup.sh"
# Dynamic generation of XDG Autostart
echo -e "${GREEN}[*] Generating absolute path XDG autostart...${NC}"
mkdir -p "$HOME/.config/autostart"

cat <<EOF > "$HOME/.config/autostart/ags-osd.desktop"
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=AGS Language OSD
Comment=Starts AGS OSD Daemon
Exec=/bin/bash $CONFIG_DIR/startup.sh
OnlyShowIn=XFCE;
Terminal=false
Hidden=false
StartupNotify=false
EOF

chmod +x "$HOME/.config/autostart/ags-osd.desktop"

Session cleanup
echo -e "${GREEN}[*] Terminating stale background processes...${NC}"
pkill ags || true

echo -e "${GREEN}[+] Deployment complete. The OSD will start automatically on next login.${NC}"
echo -e "${GREEN}[+] To start immediately without reboot, run: /bin/bash $CONFIG_DIR/startup.sh &${NC}"