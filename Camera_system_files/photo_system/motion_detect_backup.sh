
# This bash script is for handling the motion detector images.




time_start=$(date +%s)


time_interval=7

first_foto=0
first_foto_json=0

second_foto=0
second_foto_json=0




while true; do
time_current=$(date +%s)
delta_time=$((time_current-time_start))


if [[ $delta_time == $time_interval ]]
then # Every 10 seconds
  time_start=$(date +%s)


  # -------- Use take photo and get the address of the newly creates jpg and json file --------
  echo "Motion detector: Taking temporary image"
  val=$(./take_photo.sh Temp)

  # Extracting the first and second values from the full output
  jpg_address=$(echo "$val" | sed -n '1p')  # Extracting the first line
  json_address=$(echo "$val" | sed -n '2p')  # Extracting the second line


  if [[ $first_foto == 0 ]]
  then
    first_foto=$jpg_address
    first_foto_json=$json_address
  else
    second_foto=$jpg_address
    second_foto_json=$json_address

    motion_var=$(python motion_detect.py $first_foto $second_foto)
  
    # No matter what, remove the first image
    rm $first_foto
    rm $first_foto_json


    if [[ "$motion_var" == "Motion detected" ]]
    then
      # Motion was detected
      # Remove the first foto, and mark the second foto with trigger motion
      echo "motion detected taking photo: " $second_foto
      
      image_json=$(cat $second_foto_json)
      # Use jq to modify the JSON file
      jq '.Trigger = "Motion"' <<< "$image_json" > temp.json
      mv temp.json "$second_foto_json"

      # Reset motion detector
      first_foto=0
      first_foto_json=0
      second_foto=0
      second_foto_json=0

    else
      # Motion was not detected

      # Remove the old image (first foto), and overwrite it with the new image (second foto). Delete the spot for the new image

      first_foto=$second_foto
      first_foto_json=$second_foto_json
      
      second_foto=0
      second_foto_json=0
    fi

  


  fi
fi
done




# -------- Use take photo and get the address of the newly creates jpg and json file --------
val=$(./take_photo.sh)

# Extracting the first and second values from the full output
jpg_address=$(echo "$val" | sed -n '1p')  # Extracting the first line
json_address=$(echo "$val" | sed -n '2p')  # Extracting the second line














