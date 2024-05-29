
# This bashscript is for coding the wildlife trigger

#!/bin/bash
 
trap ctrl_c INT
 
function ctrl_c() { 
    echo "Wildlife trigger exited"
    exit 0 
}

subcribe() {
    #MWTT desired publisher
    mosquitto_sub -d -h localhost -u my_user -P my_password -t my_user/count
}

debounce_time=15 # In seconds
last_processed_time=$(date +%s)

 
topic_name="mosquitto_sub -d -h localhost -u my_user -P my_password -t my_user/count"
 

  
while read topic 
do 
     current_time=$(date +%s)
     
     var=$((current_time - last_processed_time))


     if [ $var -ge $debounce_time ]; then
        # Update the last processed message time
        last_processed_time=$current_time

        # Append timestamp to the message 
        

	echo "Wildlife trigger activated: "
     # Actions when receiving message goes in here ---------------
        val=$(./take_photo.sh Trigger)
        
        # Extracting the first and second values from the full output
        jpg_address=$(echo "$val" | sed -n '1p')  # Extracting the first line
        json_address=$(echo "$val" | sed -n '2p')  # Extracting the second line


     # end ------------------------------------------------------
     fi
done < <(subcribe)



