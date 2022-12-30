#!/bin/bash

status_filename=~/Battery/.battery_status
truncate -s 0 $status_filename
echo "false" >> $status_filename

pidbattery_monitor=$(pgrep -f battery_monitor.sh)
if [ -z "${pidbattery_monitor}" ]; then
    echo "No battery monitor process"
else
    kill -9 $pidbattery_monitor
fi

