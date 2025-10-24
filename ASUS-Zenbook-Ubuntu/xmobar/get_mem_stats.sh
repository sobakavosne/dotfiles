#!/bin/bash

mem_usage=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100}')

printf "RAM: %05.1f%%" "$mem_usage" | sed 's/^RAM: 0/RAM: <fc=#000000>0<\/fc>/' | sed 's/RAM: /<fc=#FFA500>RAM: <\/fc>/'
