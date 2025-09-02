#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/colors.sh"
ts=$(tailscale status > /dev/null)

# if exit code is 0
if [ $? -eq 0 ]; then
  sketchybar -m --set tailscale label.color=$COLOR_SUCCESS
else
  sketchybar -m --set tailscale label.color=$COLOR_WARNING
fi
