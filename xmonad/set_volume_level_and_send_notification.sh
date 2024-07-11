#!/bin/bash

increasing_volume_level=""

while getopts "l:" opt; do
  case ${opt} in
    l )
      increasing_volume_level=$OPTARG
      ;;
  esac
done

pactl set-sink-volume @DEFAULT_SINK@ $increasing_volume_level

current_volume_level=$(pactl get-sink-volume @DEFAULT_SINK@ | grep 'Volume:' | head -n 1 | awk '{print $5}' | sed 's/%//')

title="Volume Level"
body="Current Volume: $current_volume_level%"

notify-send "$title" "$body" -h string:x-canonical-private-synchronous:volume -h int:value:"$current_volume_level" -t 3000
