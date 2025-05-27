#!/bin/bash

# Lock only if not already locked
if ! pgrep -x "i3lock" >/dev/null; then
  # Clean up old images
  rm -f /tmp/screen_locked.png /tmp/screen_locked_blur.png /tmp/lockscreen.png

  # Take a screenshot
  scrot /tmp/screen_locked.png

  # Blur the screenshot
  convert /tmp/screen_locked.png -blur 0x10 /tmp/screen_locked_blur.png

  # Get current screen resolution
  RES=$(xrandr | grep '*' | awk '{print $1}')

  # Resize blurred image to screen resolution
  convert /tmp/screen_locked_blur.png -resize "$RES"\! /tmp/lockscreen.png

  # Reset keyboard layout
  setxkbmap us

  # Lock the screen with the blurred image
  i3lock -i /tmp/lockscreen.png
fi

