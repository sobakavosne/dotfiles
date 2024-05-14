#!/bin/bash

# Check if Bluetooth service is active
if systemctl is-active --quiet bluetooth; then
	    echo "BT:On |" # Bluetooth is active
    else
	    echo "BT:Off |" # Bluetooth is not active
fi
