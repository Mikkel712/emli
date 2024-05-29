
#Time trigger  every 5 minutes
time_start=$(date +%s)
while true; do
    time_current=$(date +%s)
    delta_time=$((time_current - time_start))
    if [ $delta_time -ge 10 ]; then #5 minutes
        # -------- Use take photo and get the address of the newly creates jpg and json file --------
        val=$(./take_photo.sh Time)

        # Extracting the first and second values from the full output
        jpg_address=$(echo "$val" | sed -n '1p')  # Extracting the first line
        json_address=$(echo "$val" | sed -n '2p')  # Extracting the second line

        echo "Photo taken due to time: "
        time_start=$(date +%s) # Reset timer
    fi
    sleep 1 # Avoid spam loop
done

