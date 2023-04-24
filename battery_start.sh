#!/bin/bash

# Use Command Output widget
# install acpi

truncate -s 0 ~/Battery/batstat
echo ' --- ' >> ~/Battery/batstat

sleep 60;


(/home/orrot/Programs/path/battery_monitor.sh) &
exit 0;
