#! /bin/bash

HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-processes.txt"

> $FILE
ps -aux | tr -s '[[:blank:]]' ' ' | while read LINE
do
        TEMP=`echo $LINE | cut -d ' ' -f 1-10 | tr ' ' ','`
        TEMP="${TEMP},`echo $LINE | cut -d ' ' -f 11-`"
        echo ${TEMP} | tr ',' \\t >> $FILE
done

exit 0

