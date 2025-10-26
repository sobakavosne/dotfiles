#!/bin/bash

# Usage function
usage() {
  echo "Usage: $0 --delta <value> or $0 -d <value>"
  echo "  --delta, -d : Specify the brightness delta. The delta should be in the form ±0.05, where 0.05 is the change in brightness."
  exit 1
}

# Initialize delta variable
delta=""

# Parse the options
PARSED_OPTIONS=$(getopt -o d: --long delta: -- "$@")
if [ $? -ne 0 ]; then
  usage
fi

eval set -- "$PARSED_OPTIONS"

while true; do
  case "$1" in
  -d | --delta)
    delta="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    usage
    ;;
  esac
done

# If delta is not provided or not in the correct format, show usage
if [[ -z "$delta" || ! "$delta" =~ ^[+-][0-9]+(\.[0-9]+)?$ ]]; then
  usage
fi

# Remove leading '+' or '-' from delta to get unsigned delta
unsigned_delta=$(echo "$delta" | sed 's/^[+-]//')
# Get the sign of the delta
sign=$(echo "$delta" | sed 's/^\(.\).*/\1/')

# Set threshold based on the sign
if [ "$sign" == "+" ]; then
  threshold=1
else
  threshold=0.05
fi

# Function to detect graphics card and set appropriate display output
detect_display_output() {
  # Check if Nvidia is being used
  if lspci | grep -i nvidia > /dev/null 2>&1; then
    # Check if nvidia-settings is available and nvidia driver is loaded
    if command -v nvidia-settings > /dev/null 2>&1 && nvidia-settings -q gpu > /dev/null 2>&1; then
      echo "eDP-1-0"
      return
    fi
  fi
  
  # Check if Radeon/AMD is being used
  if lspci | grep -i "radeon\|amd" > /dev/null 2>&1; then
    echo "eDP"
    return
  fi
  
  # Default fallback - try to detect from xrandr output
  if xrandr | grep -q "eDP-1-0"; then
    echo "eDP-1-0"
  elif xrandr | grep -q "eDP"; then
    echo "eDP"
  else
    # Ultimate fallback
    echo "eDP-1-0"
  fi
}

# Get the appropriate display output
display_output=$(detect_display_output)

# Get current brightness
current_brightness=$(xrandr --verbose | grep -i brightness | cut -f2 -d ' ')

# Calculate new brightness
if [ "$sign" == "+" ]; then
  new_brightness=$(awk "BEGIN {print $current_brightness + $unsigned_delta}")
else
  new_brightness=$(awk "BEGIN {print $current_brightness - $unsigned_delta}")
fi

# Clamp the new brightness to the range [0.05, 1]
if (($(echo "$new_brightness > 1" | bc -l))); then
  new_brightness=1
elif (($(echo "$new_brightness < 0.05" | bc -l))); then
  new_brightness=0.05
fi

# Set new brightness
xrandr --output "$display_output" --brightness "$new_brightness"

# Get the new brightness level as a percentage
current_brightness_level=$(awk "BEGIN {printf \"%.0f%%\", $new_brightness * 100}")

# Notification title and body
title="Brightness Level"
body="Current Brightness: $current_brightness_level"

# Send notification
notify-send "$title" "$body" -h string:x-canonical-private-synchronous:brightness -h int:value:"$current_brightness_level" -t 3000
