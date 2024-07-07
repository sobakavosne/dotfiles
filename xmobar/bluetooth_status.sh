#!/bin/bash

# Check if Bluetooth service is active
if systemctl is-active --quiet bluetooth; then
    # Bluetooth is active
    devices=$(bluetoothctl devices | awk '{print $2}' | while read -r mac; do
        info=$(bluetoothctl info "$mac")
        if echo "$info" | grep -q "Connected: yes"; then
            echo "$info" | grep "Alias" | awk -F ': ' '{print $2}'
        fi
    done)

    if [ -z "$devices" ]; then
        echo "No devices connected |"
    else
        echo "$devices |"
    fi
else
    # Bluetooth is not active
    echo "BT:Off |"
fi