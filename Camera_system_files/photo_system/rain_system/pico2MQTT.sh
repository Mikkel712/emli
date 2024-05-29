#!/bin/bash
# This code listens to the pico and sends rain sensor commands through MQTT


# Serial port
SERIAL_PORT="/dev/ttyACM0"
BAUD_RATE=115200

# Function used to read the data from the Pico
read_data() {
  timeout 0.1 cat "$SERIAL_PORT"
}

# Configure the serial port.
stty -F "$SERIAL_PORT" "$BAUD_RATE" raw -echo

# Main loop
while true; do
  # Read data from the Pico
  data=$(read_data)
  
  # Parse JSON data and extract rain_detect value
  rain_detect=$(echo "$data" | jq -r '.rain_detect // 0')

  if ! [ -z $rain_detect ]; then
  if [ $rain_detect == 1 ]; then
     echo "sending wipe request"
     mosquitto_pub -h localhost -p 1883 -u my_user -P my_password -t rain_detector -m RAINWIPE_REQUESTED
  fi 
  fi
 
  done


