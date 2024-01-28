#! /bin/bash
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-physicalMEM-info.txt"
echo "Physical Memory" > $FILE
echo "Capacity (GB)" >> $FILE
TEMP=`vmstat -s | grep "total memory" | awk '{print $1}' | tr -s '[[:blank:]]' ' ' | sed 's/ //'`
MEMSIZE=$(echo "scale=2; $TEMP / 1024 / 1024" | bc -l)
echo $MEMSIZE >> $FILE

echo -e "\n" >> $FILE

exit 0