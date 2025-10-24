#!/bin/bash

# Function to check if any media is playing
check_media_playing() {
  # Check playerctl (covers most media players)
  if playerctl status 2>/dev/null | grep -q 'Playing'; then
    return 0
  fi
  
  # Check for common video players
  if pgrep -f "(vlc|mpv|mplayer|smplayer|totem|parole|banshee|rhythmbox|amarok|clementine|audacious|deadbeef)" >/dev/null; then
    return 0
  fi
  
  # Check for browser-based video (YouTube, Netflix, etc.)
  if pgrep -f "(firefox|chrome|chromium|brave|opera)" >/dev/null; then
    # Check if browser has fullscreen video (basic heuristic)
    if xwininfo -root -children | grep -i "fullscreen\|video" >/dev/null; then
      return 0
    fi
  fi
  
  # Check for streaming services
  if pgrep -f "(spotify|netflix|hulu|disney|prime)" >/dev/null; then
    return 0
  fi
  
  return 1
}

# Function to disable screen dimming and saver
disable_screen_power_management() {
  # Disable screen saver
  xset s off
  # Disable DPMS (Display Power Management Signaling) to prevent dimming
  xset -dpms
  # Reset screen saver timeout
  xset s noblank
}

# Function to enable screen dimming and saver
enable_screen_power_management() {
  # Enable screen saver
  xset s on
  # Enable DPMS with reasonable timeouts (5 min standby, 10 min suspend, 15 min off)
  xset dpms 300 600 900
  # Set screen saver timeout to 10 minutes
  xset s 600
}

if check_media_playing; then
  # Prevent screen lock and dimming if media is playing
  disable_screen_power_management
  # Store state for debugging
  echo "$(date): Media detected, screen power management disabled" >> /tmp/media_check.log
else
  # Enable screen lock and dimming if no media is playing
  enable_screen_power_management
  # Check if the screen is already locked
  if ! pgrep -x "i3lock" >/dev/null; then
    rm -f /tmp/screen_locked.png /tmp/screen_locked_blur.png /tmp/lockscreen.png

    scrot /tmp/screen_locked.png

    convert /tmp/screen_locked.png -blur 0x10 /tmp/screen_locked_blur.png

    RES=$(xrandr | grep '*' | awk '{print $1}')

    IMAGE="/tmp/screen_locked_blur.png"

    TEMP_IMAGE="/tmp/lockscreen.png"

    convert "$IMAGE" -resize "$RES"\! "$TEMP_IMAGE"

    setxkbmap us

    i3lock -i "$TEMP_IMAGE"
    
    echo "$(date): No media detected, screen locked" >> /tmp/media_check.log
  fi
fi
