#!/bin/bash

HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-services.txt"
data="/tmp/$HOSTNAME-data.txt"
echo -e "Name\tDefault Status\tStatus\tDescription" > $FILE

#systemctl list-unit-files --type=service -all | sed 1d | head -n -2 | while read LINE
systemctl list-units --type=service -all | sed 1d | head -n -7 | while read LINE
do
	# Remove the ● that can appear for some daemons
	LINE=`echo $LINE | sed 's/● //'`
	name=`echo "$LINE" | awk -F' ' '{print $1}'` # | awk -F'.' '{print $1}'`
    status=`echo $LINE | awk -F' ' '{print $4}'`

    # The vendor default should be the default status for the daemon. If a better command is found please use it.
	default=`systemctl status $name 2>/dev/null | grep "vendor preset" | awk -F':' '{print $3}' | sed 's/)//' | sed 's/ //'`

    # We split on the current status of the daemon since the description can (and most likely will) have whitespace in it.
    description=`echo $LINE | awk -F$status '{print $2}' | sed 's/^ //'`

	# Remove the .service part of the name, just in case keeping it helps match things better.
    name=`echo "$name" | awk -F'.' '{print $1}'`
	echo -e "$name\t$default\t$status\t$description" >> $FILE
    echo "service|$name|$default|$status|$description" >> $data
done
