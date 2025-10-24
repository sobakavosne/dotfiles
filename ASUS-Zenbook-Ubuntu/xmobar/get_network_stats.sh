#!/bin/bash

# Network monitoring script for xmobar
# Provides colored output with fixed width and invisible leading zeros

# Get network interface (assuming wlp3s0)
interface="wlp3s0"

# Create temp file for previous values if it doesn't exist
temp_file="/tmp/network_stats_$interface"
if [ ! -f "$temp_file" ]; then
    echo "0 0" > "$temp_file"
fi

# Get current network stats
rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)

# Read previous values
read prev_rx prev_tx < "$temp_file"

# Calculate speed (bytes per second)
# Get the actual interval from xmobar (5 seconds)
interval=5
rx_speed=$(( (rx_bytes - prev_rx) / interval ))
tx_speed=$(( (tx_bytes - prev_tx) / interval ))

# Save current values for next run
echo "$rx_bytes $tx_bytes" > "$temp_file"

# Convert to human readable format (KB/s or MB/s)
if [ $rx_speed -gt 1024 ]; then
    rx_display=$(echo "scale=1; $rx_speed/1024" | bc -l 2>/dev/null || echo "0")
    rx_unit="MB/s"
else
    rx_display=$(echo "scale=1; $rx_speed" | bc -l 2>/dev/null || echo "0")
    rx_unit="KB/s"
fi

if [ $tx_speed -gt 1024 ]; then
    tx_display=$(echo "scale=1; $tx_speed/1024" | bc -l 2>/dev/null || echo "0")
    tx_unit="MB/s"
else
    tx_display=$(echo "scale=1; $tx_speed" | bc -l 2>/dev/null || echo "0")
    tx_unit="KB/s"
fi

# Format with fixed width and color
printf "NET: %05.1f%s↓ %05.1f%s↑" "$rx_display" "$rx_unit" "$tx_display" "$tx_unit" | \
sed 's/NET: 0/NET: <fc=#000000>0<\/fc>/' | \
sed 's/ 0/ <fc=#000000>0<\/fc>/' | \
sed 's/NET: /<fc=#32CD32>NET: <\/fc>/' | \
sed 's/↓ /<fc=#FFFFFF>↓ <\/fc>/' | \
sed 's/↑ /<fc=#FFFFFF>↑ <\/fc>/'