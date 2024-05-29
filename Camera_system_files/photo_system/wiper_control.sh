#!/bin/bash

# Serial port
SERIAL_PORT="/dev/ttyACM0"
BAUD_RATE=115200

# Function used to send the data to the Pico
send_data() {
  local angle=$1
  echo -ne "{\"wiper_angle\": $angle}\n" > "$SERIAL_PORT"
}

# Function used to read the data from the Pico
read_data() {
  timeout 0.1 cat "$SERIAL_PORT"
}

# Function to perform the moving of the servo based on rain_detect value.
perform_action() {
  local rain_detect=$1
  echo "Received data: $data"

  if [ -z "$rain_detect" ]; then
    rain_detect=0
  fi

  if [ "$rain_detect" -eq 1 ]; then
    echo "Received data: $data"
    send_data 0
    sleep 0.3  #Here i use sleep to not make it do it to quickly
    send_data 180
    sleep 0.3
    send_data 0
  fi
}

# Configure the serial port.
stty -F "$SERIAL_PORT" "$BAUD_RATE" raw -echo

# Main loop
while true; do
  # Read data from the Pico
  data=$(read_data)
  
  # Parse JSON data and extract rain_detect value
  rain_detect=$(echo "$data" | jq -r '.rain_detect // 0')

  # Perform action based on rain_detect value
  perform_action "$rain_detect"
done
