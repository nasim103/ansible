#! /bin/bash
Date=`date`
#Author=Nasim Ahmad
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-logicaldisk-info.txt"
data="/tmp/$HOSTNAME-data.txt"

echo "Logical Storage" >> $FILE
echo -e "Device ID\tLogical Storage Name\tCapacity (in GB)\tUsed Space (in GB)\tAvailable Space (in GB)\t% Available" >> $FILE

sudo /sbin/lvdisplay | sed -n '2~17p' | while read LINE
do
    path=`echo "$LINE" | awk '{print $3}'`
    name=`sudo lvdisplay $path | grep "LV Name" | awk '{print $3}'`
    volume=`sudo lvs --segments | grep $name  | awk '{print $2}'`
    #total=`sudo lvs --segments | grep $name  | awk '{print $6}'`
    total=0
    sudo lvs --segments | grep $name  | awk '{print $6}' | ( while read LINE2
    do
        size=`echo "${LINE2: -1}"`
        LINE2=`echo "$LINE2" | sed 's/[a-z]//' | sed 's/<//'`
        if [[ $size == "m" ]]; then
                LINE2=$(echo "scale=2; $LINE2 / 1024" | bc -l)
        fi
        total=$(echo "scale=2; ($total + $LINE2)" | bc -l)
    done

    pe=`sudo vgdisplay $volume | grep "PE Size" | awk '{print $3}'`
    le=`sudo lvdisplay $path | grep "Current LE" | awk '{print $3}'`

    used=$(echo "scale=2; ($le * $pe) / 1024" | bc -l)
    available=$(echo "scale=2; $total - $used" | bc -l)

    percent=$(echo "scale=2; 100 - (($used / $total) * 100)" | bc -l)

    echo -e "$path\t$name\t$total\t$used\t$available\t$percent%" >> $FILE 
    echo "logical|$name|$total|$used|$available" >> $data )
done

echo -e "\n" >> $FILE
