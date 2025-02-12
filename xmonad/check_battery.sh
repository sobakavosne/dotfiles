#!/bin/bash

LOW_BATTERY_THRESHOLD=20
NOTIFICATION_ID_FILE="/tmp/battery_notification_id"

send_notification() {
    if [ ! -f "$NOTIFICATION_ID_FILE" ]; then
        echo "Sending low battery notification"
        NOTIFICATION_ID=$(dunstify -u critical "Low Battery" "Battery level is ${BATTERY_LEVEL}%. Please plug in your charger." -p)
        if [[ "$NOTIFICATION_ID" =~ ^[0-9]+$ ]]; then
            echo "$NOTIFICATION_ID" > "$NOTIFICATION_ID_FILE"
        fi
    else
        echo "Low battery notification already sent. Skipping."
    fi
}

dismiss_notification() {
    if [ -f "$NOTIFICATION_ID_FILE" ]; then
        echo "Dismissing low battery notification"
        NOTIFICATION_ID=$(cat "$NOTIFICATION_ID_FILE")
        if [[ "$NOTIFICATION_ID" =~ ^[0-9]+$ ]]; then
            dunstify -C "$NOTIFICATION_ID"
        fi
        rm -f "$NOTIFICATION_ID_FILE"
        dunstify -u low "Battery Charging" "Battery is now charging."
    else
        echo "No low battery notification to dismiss."
    fi
}

while true; do
    BATTERY_INFO=$(acpi -b)
    BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep -oP '(?<=Battery 0: )\w+')
    BATTERY_LEVEL=$(echo "$BATTERY_INFO" | grep -oP '[0-9]+(?=%)')

    echo "Raw Battery Info: $BATTERY_INFO"
    echo "Battery Status: $BATTERY_STATUS"
    echo "Battery Level: $BATTERY_LEVEL"

    if [[ "$BATTERY_STATUS" == "Discharging" ]]; then
        if [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ]; then
            send_notification
        fi
    elif [[ "$BATTERY_STATUS" == "Charging" ]]; then
        dismiss_notification
    else
        echo "Battery status is Full or Unknown. No action needed."
    fi

    sleep 1
done

