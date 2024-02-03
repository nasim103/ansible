#! /bin/bash

HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-physicalstorage-info.txt"
data="/tmp/$HOSTNAME-data.txt"

echo "Physical Storage" >> $FILE
echo -e "Device ID\tCapacity (GB)\tAvailable Space (GB)\tUsed Space (GB)" >> $FILE

sudo /sbin/pvdisplay | sed -n '2~11p' | while read LINE
do
	name=`echo "$LINE" | awk '{print $3}'`
    capacity=`sudo /sbin/pvdisplay $name | grep "PV Size" | awk '{print $3}'`
	#Doing a little bit of math here to determine how much space is available and how much has been used
	#The space is measured in PE's (physical extents) where the default size of the PE is assumed to be 4.00MiB
	TOTAL=`sudo /sbin/pvdisplay $name | grep "Total PE" | awk '{print $3}'`
	ALLOCATED=`sudo /sbin/pvdisplay $name | grep "Allocated PE" | awk '{print $3}'`
    #Gives the available space in GiB's (essentially GB in base 2 form instead of base 10)
	AVAILABLE=$(echo "scale=2; ($TOTAL-$ALLOCATED) * 4 / 1024" | bc -l)
	#Calculates the used space in GiB's (essentially GB in base 2 form instead of base 10)
	USED=$(echo "scale=2; $ALLOCATED * 4 / 1024" | bc -l)

	echo -e "$name\t$capacity\t$AVAILABLE\t$USED" >> $FILE
    # Order is different based on the way we send data to the database
    echo "physical|$name|$capacity|$USED|$AVAILABLE" >> $data    
done

echo -e "\n" >> $FILE

exit 0
