#!/bin/bash

PI_USERNAME="nates"
PI_HOST="192.168.10.1"
PI_DIRECTORY="~/final_assignment/photo_system/photos"
PASSWORD="3ates"
LOCAL_DIRECTORY="./emli/photos_collected"
LOCAL_DIRECTORY_SQL="./emli/sql"
SSID="EMLI-TEAM-8"

# path for the sql
DB_PATH="$LOCAL_DIRECTORY_SQL/wifi_log.db"

# createing SQLite database and table 
sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS wifi_log (
    epoch INTEGER PRIMARY KEY,
    link_quality INTEGER,
    signal_level INTEGER
);
EOF

# function to log WiFi data into sql.
log_wifi_data() {
    while true; do
        if nmcli device wifi list | grep -q "$SSID"; then
            # get current epoch time
            epoch=$(date +%s)
            
            # get WiFi link quality and signal level
            link_quality=$(awk '/wlp3s0/ {print $3}' /proc/net/wireless | tr -d '.')
            signal_level=$(awk '/wlp3s0/ {print $4}' /proc/net/wireless | tr -d '.') #dBm

            # insert data into the database
            sqlite3 "$DB_PATH" <<EOF
INSERT INTO wifi_log (epoch, link_quality, signal_level)
VALUES ($epoch, '$link_quality', '$signal_level');
EOF
        else
            echo "No Wi-Fi network found: $SSID"
        fi
        sleep 2
    done
}

# date
NOW=$(date +'%Y-%m-%d')
echo "Current date: $NOW"

#create folder with the name of the current date
mkdir -p "$LOCAL_DIRECTORY/$NOW"

# start logging WiFi data in the background
log_wifi_data &

# capture the process ID in the background
LOG_WIFI_PID=$!

# main loop 
while true; do
    #check if the wifi network is found:
    if nmcli device wifi list | grep -q "$SSID"; then
        echo "Wi-Fi network found: $SSID"
                
        # connecting to the Wi-Fi network
        if nmcli device wifi connect "$SSID"; then
            # get the new images from the wildlife camera
            sshpass -p "$PASSWORD" scp "$PI_USERNAME@$PI_HOST:$PI_DIRECTORY/$NOW/*.jpg" "$LOCAL_DIRECTORY/$NOW"
            sshpass -p "$PASSWORD" scp "$PI_USERNAME@$PI_HOST:$PI_DIRECTORY/$NOW/*.json" "$LOCAL_DIRECTORY/$NOW"
            
            # iterate over JPG files
            for jpg_file in "$LOCAL_DIRECTORY/$NOW"/*.jpg; do
                filename=$(basename "$jpg_file")
                json_file="${jpg_file%.jpg}.json"
                
                # check if JSON file exists
                if [ -f "$json_file" ]; then
                    
                    #echo "this is what you give the ai"
                    #echo "describe \"$jpg_file\""
                    ollama_output=$(ollama run llava:7b "describe \"$jpg_file\" in a single sentence")
                    echo "ollama_output:"
                    echo $ollama_output
                    
                    # insert ollama_output into JSON file
                    jq --arg ollama_output "$ollama_output" '. + {"Annotation": {"Source": "Ollama:7b", "Result": $ollama_output}}' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"

                    # functional requirement I)
                    # seconds_epoch=$(date +%s.%N)
                    # jq --arg seconds_epoch "$seconds_epoch" '. + {"Drone Copy": {"Drone ID": "WILDDRONE-001", "Seconds Epoch": $seconds_epoch}}' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
                fi
            done

            break
        else
            echo "Error: Failed to connect to Wi-Fi network $SSID"
        fi
    else
        echo "No Wi-Fi network found."
    fi
    sleep 2
done

# terminate background logging process
kill $LOG_WIFI_PID


#git
cd emli
git add .
git commit -m "delivered new JSON files"
git push
