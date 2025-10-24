#!/bin/bash

# AMD GPU monitoring script for xmobar
# Monitors AMD integrated GPU

# Check for AMD GPU with radeontop
if command -v radeontop &> /dev/null; then
    gpu_util=$(radeontop -d- -l1 | grep -o 'gpu [0-9]*%' | head -1 | sed 's/gpu //' | sed 's/%//')
    # Format with decimal precision and consistent width
    gpu_util=$(printf "%.1f" "$gpu_util")
    printf "AMD: %05.1f%%" "$gpu_util" | sed 's/^AMD: 0/AMD: <fc=#000000>0<\/fc>/' | sed 's/AMD: /<fc=#87CEEB>AMD: <\/fc>/'
    exit 0
fi

# Check for AMD GPU with sysfs
if [ -f /sys/class/drm/card*/device/gpu_busy_percent ]; then
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        if [ -f "$card" ]; then
            gpu_util=$(cat "$card")
            # Format with decimal precision and consistent width
            gpu_util=$(printf "%.1f" "$gpu_util")
            printf "AMD: %05.1f%%" "$gpu_util" | sed 's/^AMD: 0/AMD: <fc=#000000>0<\/fc>/' | sed 's/AMD: /<fc=#87CEEB>AMD: <\/fc>/'
            exit 0
        fi
    done
fi

# Fallback
echo "AMD: N/A"
