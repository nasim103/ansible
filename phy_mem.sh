#! /bin/bash

HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-phy-mem-info.txt"

echo "Physical Memory Array" >> $FILE
echo -e "Maximum Capacity (GB)\tMemory Devices\tUsage" >> $FILE

TEMP=`sudo dmidecode -t 16 | grep "Maximum Capacity" | awk -F: '{print $2}' | sed 's/ //'`
TEMP="${TEMP},`sudo dmidecode -t 16 | grep "Number Of Devices" | awk -F: '{print $2}' | sed 's/ //'`"
TEMP="${TEMP},`sudo dmidecode -t 16 | grep "Use" | awk -F: '{print $2}' | sed 's/ //'`"

echo -e ${TEMP} | tr ',' \\t >> $FILE

echo -e "\n" >> $FILE

exit 0
