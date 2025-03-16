#!/bin/bash

current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep 'Volume:' | head -n 1 | awk '{print $5}' | sed 's/%//')

echo "Volume: ${current_volume}%"

