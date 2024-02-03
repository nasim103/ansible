#! /bin/bash
#Author=Nasim Ahmad
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-network.txt"
data="/tmp/$HOSTNAME-data.txt"
echo "Network Card" >> $FILE
echo -e "Device ID\tManufacturer and Model\tMAC Address\tMaximum Speed (in KB/s)\tStatus\tProduct Name\tAdaptor Type" >> $FILE
# Get all the network interfaces
ip addr | grep -e "^[0-9]" | awk '{print $2}' | sed 's/.$//' | while read LINE
do
	STATUS=`ethtool $LINE | grep "Link detected:" | awk '{print $3}'`

	if [[ "$STATUS" == "yes" ]]
	then
		STATUS="UP"
	else
		STATUS="DOWN"
	fi

    if [[ $LINE == "lo" ]] 
    then
		echo -e "$LINE\t\tVirtual Interface\t\t$STATUS\t$LINE\tVirtual" >> $FILE
    else   
    	# This line gets the slot number, if possible, to look up the CONTROLLER 
		SLOT=`ethtool -i $LINE | grep "bus-info" | awk '{print $2}'`

	   	# If the slot number is not a number then we stop looking things up for it
	   	if [[ "${SLOT:0:2}" == "00"  ]]
	   	then
	        # Get the CONTROLLER information
			CONTROLLER=`lspci | grep "${SLOT:5}" | cut -d ' ' -f4-`
	        # Get the interface's MAC address
	        MAC=`sed '1q' /sys/class/net/$LINE/address`
	        # Get the speed of the interface
	        SPEED=`ethtool $LINE | grep Speed | awk '{print $2}' | tr -d 'Mb/s'`
	   		echo -e "$LINE\t$CONTROLLER\t$MAC\t$(($SPEED * 1024))\t$STATUS\t$LINE\tPhysical" >> $FILE
            echo -e "networkcard|$LINE|$CONTROLLER|$MAC|$(($SPEED * 1024))|$STATUS|$LINE|Physical" >> $data
	   	else
			echo -e "$LINE\t\tVirtual Interface\t\t$STATUS\t$LINE\tVirtual" >> $FILE
            echo -e "networkcard|$LINE||Virtual Interface||$STATUS|$LINE|Virtual" >> $data
	   	fi
	fi
done

echo -e "\n" >> $FILE
