#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# $FOCUSED_WORKSPACE is supplied by the aerospace_workspace_change trigger
# (see aerospace.toml). On first load it's empty, so fall back to querying.
WS="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

sketchybar --set "$NAME" label="$WS"
