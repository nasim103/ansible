#! /bin/bash
Date=`date`
#Author=Nasim Ahmad
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-group.txt"
echo -e "Full Name\tName\tGID" >> $FILE
pr -l 1 /etc/group | while read LINE
do
	name=`echo ${LINE} | cut -d ':' -f1` 
	id=`echo ${LINE} | cut -d ':' -f3`
    # Alternate idea if lid is not always installed. Try to find the gid in /etc/passwd.
    # That may tell us who the primary user is.
	echo -e "$name\t$name\t$id" >> $FILE
done

