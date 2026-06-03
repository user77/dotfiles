#!/bin/bash

# Target device names from 'hyprctl devices'
TOUCHPAD="synps/2-synaptics-touchpad"
TRACKPOINT="tpps/2-elan-trackpoint"

# Time in seconds to keep touchpad disabled after TrackPoint movement stops
TIMEOUT=0.5

PID_FILE="/tmp/trackpoint_timeout.pid"

disable_touchpad() {
  hyprctl keyword "device:$TOUCHPAD:enabled" false >/dev/null

  # Kill any existing timeout instance
  if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null
    rm "$PID_FILE"
  fi

  # Start a background timer to re-enable the touchpad
  (
    sleep "$TIMEOUT"
    hyprctl keyword "device:$TOUCHPAD:enabled" true >/dev/null
    rm "$PID_FILE"
  ) &
  echo $! >"$PID_FILE"
}

# Use absolute path to libinput
/usr/bin/libinput debug-events | while read -r line; do
  if [[ "$line" == *"$TRACKPOINT"* && "$line" == *"POINTER_MOTION"* ]]; then
    disable_touchpad
  fi
done
