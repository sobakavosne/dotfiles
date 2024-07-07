#!/bin/bash

current_brightness=$(xrandr --verbose | awk '/Brightness/ { printf("%.0f%%\n", $2 * 100) }')

echo "Brightness: ${current_brightness}"
