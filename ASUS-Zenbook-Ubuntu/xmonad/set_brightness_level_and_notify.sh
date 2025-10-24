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
xrandr --output eDP-1-0 --brightness "$new_brightness"

# Get the new brightness level as a percentage
current_brightness_level=$(awk "BEGIN {printf \"%.0f%%\", $new_brightness * 100}")

# Notification title and body
title="Brightness Level"
body="Current Brightness: $current_brightness_level"

# Send notification
notify-send "$title" "$body" -h string:x-canonical-private-synchronous:brightness -h int:value:"$current_brightness_level" -t 3000
