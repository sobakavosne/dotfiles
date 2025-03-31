#!/bin/bash

LOW_BATTERY_THRESHOLD=15
NOTIFICATION_ID_FILE="/tmp/battery_notification_id"

send_notification() {
  if [ ! -f "$NOTIFICATION_ID_FILE" ]; then
    echo "Sending notification"
    NOTIFICATION_ID=$(dunstify -u critical "Low Battery" "Battery level is ${BATTERY_LEVEL}%. Please plug in your charger." -p)
    if [[ "$NOTIFICATION_ID" =~ ^[0-9]+$ ]]; then
      echo $NOTIFICATION_ID >$NOTIFICATION_ID_FILE
    fi
  fi
}

dismiss_notification() {
  if [ -f "$NOTIFICATION_ID_FILE" ]; then
    echo "Dismissing notification"
    NOTIFICATION_ID=$(cat $NOTIFICATION_ID_FILE)
    if [[ "$NOTIFICATION_ID" =~ ^[0-9]+$ ]]; then
      dunstify -C "$NOTIFICATION_ID"
    fi
    rm -f $NOTIFICATION_ID_FILE
    notify-send -u low -c "battery" -i none "Dismiss" "Battery is now charging."
  fi
}

while true; do
  BATTERY_INFO=$(acpi -b)
  BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep -oP '(Discharging|Charging|Full)')
  BATTERY_LEVEL=$(echo "$BATTERY_INFO" | grep -P -o '[0-9]+(?=%)')

  echo "Battery Status: $BATTERY_STATUS"
  echo "Battery Level: $BATTERY_LEVEL"

  if [[ "$BATTERY_STATUS" == "Discharging" ]]; then
    if [ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ]; then
      send_notification
    fi
  else
    dismiss_notification
  fi

  sleep 1
done
