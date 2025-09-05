#!/usr/bin/env bash

APP_ID=$1
APP_NAME=$2

focus_app() {
  current_workspace=$(aerospace list-workspaces --focused)
  app_window_id=$(aerospace list-windows --all --format "%{window-id}%{right-padding} | %{app-name}" | grep $APP_NAME | cut -d' ' -f1 | sed '1p;d')
  aerospace focus --window-id $app_window_id
  aerospace move-mouse window-lazy-center
}

app_closed() {
  if [ "$(aerospace list-windows --all --format '%{app-name}' | grep $APP_NAME)" == "" ]; then
    true
  else
    false
  fi
}

app_focused() {
  if [ "$(aerospace list-windows --focused --format "%{app-bundle-id}")" == "$APP_ID" ]; then
    true
  else
    false
  fi
}

unfocus_app() {
  aerospace move-node-to-workspace scratchpad
}

if app_closed; then
  echo "App is closed"
else
  if app_focused; then
    echo "App is already focus"
  else
    focus_app
  fi
fi
