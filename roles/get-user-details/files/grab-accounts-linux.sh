#!/bin/bash

HOSTNAME=`hostname -s`
INVENTORY_NAME=${1}

file="/tmp/$INVENTORY_NAME-grab-accounts-linux.csv"> $file

#echo -e "Username\tGroups\tLast Login\tAccount Locked"
cat /etc/passwd | while read LINE
do
        username=`echo $LINE | awk -F':' '{print $1}'`
        access=`sudo -l -U $username 2>/dev/null`
        if [[ $? == 0 ]]; then
                lastLog=`last -R -n 1 $username | awk '/still logged in/ {print $3,$4,$5,$6}'`
                if [[ $lastLog != *':'* ]]; then
                        lastLog="N/A"
                fi
                        locked=`sudo passwd -S $username`
                if [[ $locked = *"Password locked."* ]]; then
                        locked=true
                else
                        locked=false
                fi
                description=`echo $LINE | awk -F':' '{print $5}'`
                groups=`groups $username | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//' | sed -e 's/^[[:space:]]*//'`
                groups=`echo ${groups// /,}`

                echo -e "$CLIENT\t$HOSTNAME\t$username\t$groups\t$locked\t$lastLog\t$description" >> $file
        fi
done

exit 0
