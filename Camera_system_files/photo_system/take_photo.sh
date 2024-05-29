
folder_location="/home/nates/final_assignment/photo_system/photos"
current_date=$(date +"%Y-%m-%d")

current_date_json=$(date +"%Y-%m-%d %H:%M:%S.%N%:z")
current_date_seconds=$(date +%s)

time_name=$(date +"%H%M%S_%3N")

type_jpg=".jpg"
type_JSON=".json"

trigger_type=$1 # Trigger type must be either Time/Motion/External


# --------------------- QUEUE TASK MANAGER -----------------------
# If not Queue is made, make the Queue
if ! test -d Queue.txt; then
  touch Queue.txt
fi


# Define name tag for Q
name="TASK: "$trigger_type


# Enter name into Queue at the last value
echo $name | cat - Queue.txt > temp && mv temp Queue.txt


# Wait in Queue until own name tag is first
while true
do
  

   tag=$( tail -n 1 Queue.txt )

if [ "$tag" == "$name" ]; then
    break
fi

   
done

# --------------------- QUEUE TASK MANAGER: end -----------------------

# Only make the folder if it does not exist
if ! test -d $folder_location/$current_date; then
  mkdir $folder_location/$current_date
fi


rpicam-still -t 0.01 -o $folder_location/$current_date/$time_name$type_jpg -v 0 --width 300 --height 230

# exiftool $folder_location/$current_date/$time_name$type_jpg  -filename -createdate -subjectdistance -exposuretime -iso


file_name=$(exiftool -S -S $folder_location/$current_date/$time_name$type_jpg -filename)

create_date=$(exiftool -S -S $folder_location/$current_date/$time_name$type_jpg -createdate)

subject_distance_raw=$(exiftool -S -S $folder_location/$current_date/$time_name$type_jpg -subjectdistance)
subject_distance="${subject_distance_raw% m}"
exposure_time=$(exiftool -S -S $folder_location/$current_date/$time_name$type_jpg -exposuretime)

ISO_val=$(exiftool -S -S $folder_location/$current_date/$time_name$type_jpg -iso)



JSON_data="$(jo "File name"=$file_name "Create Date"=$current_date_json "Create Seconds Epoch"=$current_date_seconds "Trigger"=$trigger_type "Subject Distance"="$subject_distance" "Exposure Time"=$exposure_time "ISO"=$ISO_val)"

echo $JSON_data > $folder_location/$current_date/$time_name$type_JSON  

echo $folder_location/$current_date/$time_name$type_jpg
echo $folder_location/$current_date/$time_name$type_JSON



# Remove name tag from Queue
head -n -1 Queue.txt > temp.txt ; mv temp.txt Queue.txt
