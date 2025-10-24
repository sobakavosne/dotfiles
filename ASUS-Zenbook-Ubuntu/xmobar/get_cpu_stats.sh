#!/bin/bash

cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.1f", 100 - $1}')

# Get CPU temperature (try different methods)
cpu_temp=$(sensors | grep "Tctl:" | awk '{print $2}' | sed 's/+//' | sed 's/°C//' | sed 's/\..*//' 2>/dev/null || echo "0")

# Force exact width with fixed format (invisible leading zeros) and color
printf "CPU: %05.1f%% | %02d°C" "$cpu_usage" "$cpu_temp" | \
sed 's/^CPU: 0/CPU: <fc=#000000>0<\/fc>/' | \
sed 's/|  0/| <fc=#000000>0<\/fc>/' | \
sed 's/| 0/| <fc=#000000>0<\/fc>/' | \
sed 's/CPU: /<fc=#90EE90>CPU: <\/fc>/' | \
sed 's/| /<fc=#FFFFFF>| <\/fc>/'
