#!/bin/bash
sleep 8

export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)

pkill -f "ags -c.*config.js"
sleep 1

/usr/local/bin/ags -c "$HOME/.config/ags/config.js" > /tmp/ags_debug.log 2>&1