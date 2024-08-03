#!/bin/bash

if playerctl status | grep -q 'Playing'; then
  # Prevent screen lock if media is playing
  xset s off
else
  # Enable screen lock if no media is playing
  xset s on
  # Check if the screen is already locked
  if ! pgrep -x "i3lock" >/dev/null; then
    rm -f /tmp/screen_locked.png /tmp/screen_locked_blur.png /tmp/lockscreen.png

    scrot /tmp/screen_locked.png

    convert /tmp/screen_locked.png -blur 0x10 /tmp/screen_locked_blur.png

    RES=$(xrandr | grep '*' | awk '{print $1}')

    IMAGE="/tmp/screen_locked_blur.png"

    TEMP_IMAGE="/tmp/lockscreen.png"

    convert "$IMAGE" -resize "$RES"\! "$TEMP_IMAGE"

    i3lock -i "$TEMP_IMAGE"
  fi
fi
