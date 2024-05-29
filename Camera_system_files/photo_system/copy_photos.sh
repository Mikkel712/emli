#!/bin/bash

SOURCE_DIR="/home/nates/final_assignment/photo_system/photos"
DEST_DIR="/var/www/html/photos"
LOG_FILE="/home/nates/final_assignment/photo_system/photos/log.txt"
# Ensure its there
mkdir -p "$DEST_DIR"

NEW_FILES=$(diff <(find "$SOURCE_DIR" -type f | sort) <(find "$DEST_DIR" -type f | sort) | grep "^<" | cut -d " " -f 2-)

# Clear log
> "$LOG_FILE"
for FILE in $NEW_FILES; do
    
    REL_PATH="${FILE#$SOURCE_DIR/}"
    mkdir -p "$DEST_DIR/$(dirname "$REL_PATH")"
    sudo cp "$FILE" "$DEST_DIR/$REL_PATH"

    if [[ "$FILE" == *.json ]]; then
        FILE_NAME="${FILE##*/}"  # Extract filename from path
        FILE_NAME="${FILE_NAME%.json}"  # Remove .json extension
        echo "New JSON file and image"  >> "$LOG_FILE"
        CREATE_DATE=$(jq -r '.["Create Date"]' "$FILE")
        SUBJECT_DISTANCE=$(jq -r '.["Subject Distance"]' "$FILE")
        EXPOSURE_TIME=$(jq -r '.["Exposure Time"]' "$FILE")
        ISO=$(jq -r '.["ISO"]' "$FILE")
        echo "Create Date: $CREATE_DATE" >> "$LOG_FILE"
        echo "Subject Distance: $SUBJECT_DISTANCE" >> "$LOG_FILE"
        echo "Exposure Time: $EXPOSURE_TIME" >> "$LOG_FILE"
        echo "ISO: $ISO" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"  # newline
    fi
done
sudo cp "$LOG_FILE" "$DEST_DIR"
