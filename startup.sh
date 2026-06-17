#!/bin/bash
if [ -z "$1" ]; then
    sleep 10
fi

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)

TARGET_STYLE=${1:-"$HOME/.config/ags/style.css"}
export OSD_THEME_PATH="$TARGET_STYLE"

pkill -f "ags -c.*config.js" || true
sleep 0.5

/usr/local/bin/ags -c "$HOME/.config/ags/config.js" > /tmp/ags_debug.log 2>&1