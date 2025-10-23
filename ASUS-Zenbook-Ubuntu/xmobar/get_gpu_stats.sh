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
        
        # Convert memory to GB
        mem_used_gb=$(echo "scale=1; $mem_used/1024" | bc -l 2>/dev/null || echo "0")
        mem_total_gb=$(echo "scale=1; $mem_total/1024" | bc -l 2>/dev/null || echo "0")
        
        echo "GPU: ${gpu_util}% | MEM: ${mem_used_gb}/${mem_total_gb}GB | ${temp}°C | ${power}W"
    done
    exit 0
fi

# Check for AMD GPU with radeontop
if command -v radeontop &> /dev/null; then
    radeontop -d- -l1 | grep -o 'gpu [0-9]*%' | head -1 | sed 's/gpu /AMD: /' | sed 's/%/% | /'
    exit 0
fi

# Check for AMD GPU with sysfs
if [ -f /sys/class/drm/card*/device/gpu_busy_percent ]; then
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        if [ -f "$card" ]; then
            gpu_util=$(cat "$card")
            echo "AMD: ${gpu_util}%"
            exit 0
        fi
    done
fi

# Fallback
echo "GPU: N/A"
