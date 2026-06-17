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

# Dynamic generation of the GJS wrapper
echo -e "${GREEN}[*] Locating GObject Introspection typelibs...${NC}"
TYPELIB_FILE=$(find /usr -name "GUtils*.typelib" 2>/dev/null | head -n 1)

if [ -n "$TYPELIB_FILE" ]; then
    TYPELIB_DIR=$(dirname "$TYPELIB_FILE")
    echo -e "${GREEN}[*] Found typelib dynamically at: $TYPELIB_DIR${NC}"
else
    echo -e "${RED}[!] GUtils typelib not found via search. Using safe fallbacks.${NC}"
    TYPELIB_DIR="/usr/local/lib:/usr/local/lib/girepository-1.0"
fi

echo -e "${GREEN}[*] Generating system-aware GJS wrapper...${NC}"

cat <<EOF | sudo tee /usr/local/bin/ags > /dev/null
#!/bin/bash
export GDK_BACKEND=x11
export GI_TYPELIB_PATH="${TYPELIB_DIR}:\${GI_TYPELIB_PATH:+:\$GI_TYPELIB_PATH}"
export LD_LIBRARY_PATH="/usr/local/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec /usr/local/bin/ags-core "\$@"
EOF

sudo chmod +x /usr/local/bin/ags

# Path resolution & Symlinks
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

# Session cleanup
echo -e "${GREEN}[*] Terminating stale background processes...${NC}"
pkill ags || true

echo -e "${GREEN}[+] Deployment complete. The OS-agnostic architecture is applied.${NC}"