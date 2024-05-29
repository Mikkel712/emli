#!/bin/bash
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
# This script starts all other relevant scripts for this code

# Reset Queue

if test -d Queue.txt; then
  rm Queue.txt
fi

#  This runs the motion detector
./motion_detect.sh&
echo "motion detector initiated"

# takes photo based on time
./time_camera_trigger.sh&
echo "time trigger initiated"


# Takes photo based on wild life trigger
echo "wildlife trigger initiated"
./wildlife_trigger.sh&

echo ""
wait
