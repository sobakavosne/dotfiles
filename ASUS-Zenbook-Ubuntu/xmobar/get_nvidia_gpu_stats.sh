#!/bin/bash

# GPU monitoring script for xmobar
# Monitors both NVIDIA and AMD GPUs

# Check for NVIDIA GPU
if command -v nvidia-smi &> /dev/null; then
    # Get NVIDIA GPU stats
    nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv,noheader,nounits | head -1 | while IFS=',' read -r gpu_util mem_used mem_total temp power; do
        # Clean up values (remove spaces)
        gpu_util=$(echo $gpu_util | tr -d ' ')
        mem_used=$(echo $mem_used | tr -d ' ')
        mem_total=$(echo $mem_total | tr -d ' ')
        temp=$(echo $temp | tr -d ' ')
        power=$(echo $power | tr -d ' ')
        
        # Format GPU utilization with decimal precision
        gpu_util=$(printf "%.1f" "$gpu_util")
        
        # Convert memory to GB with consistent formatting
        mem_used_gb=$(echo "scale=1; $mem_used/1024" | bc -l 2>/dev/null | sed 's/^\./0./' || echo "0.0")
        mem_total_gb=$(echo "scale=1; $mem_total/1024" | bc -l 2>/dev/null | sed 's/^\./0./' || echo "0.0")
        
        # Ensure memory values have consistent width
        mem_used_gb=$(printf "%4s" "$mem_used_gb")
        mem_total_gb=$(printf "%4s" "$mem_total_gb")
        
        # Format power and temperature with decimal precision for consistent width
        power=$(printf "%.1f" "$power")
        temp=$(printf "%.0f" "$temp")
        
        # Force exact width with fixed format - no jumping possible (invisible leading zeros) and colors
        printf "NVIDIA: %05.1f%% | %02.0f°C" "$gpu_util" "$temp" | \
        sed 's/NVIDIA: 0/NVIDIA: <fc=#000000>0<\/fc>/' | \
        sed 's/|  0/| <fc=#000000>0<\/fc>/' | \
        sed 's/| 0/| <fc=#000000>0<\/fc>/' | \
        sed 's/NVIDIA: /<fc=#FF6B6B>NVIDIA: <\/fc>/' | \
        sed 's/| /<fc=#FFFFFF>| <\/fc>/'
    done
    exit 0
fi

# Check for AMD GPU with radeontop
if command -v radeontop &> /dev/null; then
    gpu_util=$(radeontop -d- -l1 | grep -o 'gpu [0-9]*%' | head -1 | sed 's/gpu //' | sed 's/%//')
    # Format with decimal precision and consistent width
    gpu_util=$(printf "%.1f" "$gpu_util")
    printf "AMD: %6s%%" "$gpu_util" | sed 's/AMD: /<fc=#87CEEB>AMD: <\/fc>/'
    exit 0
fi

# Check for AMD GPU with sysfs
if [ -f /sys/class/drm/card*/device/gpu_busy_percent ]; then
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        if [ -f "$card" ]; then
            gpu_util=$(cat "$card")
            # Format with decimal precision and consistent width
            gpu_util=$(printf "%.1f" "$gpu_util")
            printf "AMD: %6s%%" "$gpu_util" | sed 's/AMD: /<fc=#87CEEB>AMD: <\/fc>/'
            exit 0
        fi
    done
fi

# Fallback
echo "GPU: N/A"
