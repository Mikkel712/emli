#!/bin/bash

# This code is for receiving MQTT values from the rainsensor and then sending rain requests.

# This is the basic structure for MQTT subscriber

#!/bin/bash
 
trap ctrl_c INT
 
function ctrl_c() { 
    echo "Wildlife trigger exited"
    exit 0 
}

subcribe() {
    #MWTT desired publisher
    mosquitto_sub -d -h localhost -p 1883 -u my_user -P my_password -t rain_detector
}

debounce_time=5 # In seconds
last_processed_time=$(date +%s)

 
topic_name="mosquitto_sub -d -h localhost -u my_user -P my_password -t my_user/count"
 
  
while read topic 
do 
     current_time=$(date +%s)

     var=$((current_time - last_processed_time))


     if [ $var -ge $debounce_time ]; then
        # Update the last processed message time
        last_processed_time=$current_time

        # Append tipinmestamp to the message 

        echo "Message received executing wipe..."

     # Actions when receiving message goes in here ---------------

         ./do_swipe.sh          
    
     # end ------------------------------------------------------
     fi
done < <(subcribe)
