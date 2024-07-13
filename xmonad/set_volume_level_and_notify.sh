#!/bin/bash

# Usage function
usage() {
  echo "Usage: $0 --delta <value> or $0 -d <value>"
  echo "  --delta, -d : Specify the volume delta. The delta should be in the form ±5%, where 5% is the change in volume."
  exit 1
}

# Parse the options
PARSED_OPTIONS=$(getopt -o d: --long delta: -- "$@")
if [ $? -ne 0 ]; then
  usage
fi

eval set -- "$PARSED_OPTIONS"

# Initialize delta variable
delta=""

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

# Check if delta is provided and matches the correct format
if [[ -z "$delta" || ! "$delta" =~ ^[+-][0-9]+%$ ]]; then
  usage
fi

# Set the volume
pactl set-sink-volume @DEFAULT_SINK@ "$delta"

# Get the current volume level
current_volume_level=$(pactl get-sink-volume @DEFAULT_SINK@ | grep 'Volume:' | head -n 1 | awk '{print $5}' | sed 's/%//')

# Notification title and body
title="Volume Level"
body="Current Volume: $current_volume_level%"

# Send notification
notify-send "$title" "$body" -h string:x-canonical-private-synchronous:volume -h int:value:"$current_volume_level" -t 3000
