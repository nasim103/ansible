#! /bin/bash
#touch "/tmp/$HOSTNAME-hardware-info.txt"
#touch "/tmp/$HOSTNAME-data.txt"
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-hardware-info.txt"
data="/tmp/$HOSTNAME-data.txt"
echo "BIOS" >> $FILE
echo -e "BIOS Name \tBIOS Date\tManufacturer\tCharacteristics" >> $FILE
TEMP=`echo "bios0"`
TEMP="${TEMP}.`dmidecode -t 0|grep -i "Release Date"| awk -F: '{print $2}'|tr -s '[[:blank:]]' ' '|sed 's/ //'`"
TEMP="${TEMP}.dmidecode -t 0|grep -i "Vendor"| awk -F: '{print $2}'|tr -s '[[:blank:]]' ' '|sed 's/ //'"
TEMP="${TEMP}.`dmidecode -t 0 |awk '/Characteristics:/{flag=1;next}/BIOS Revision/{flag=0}flag'|tr -s '[[:blank:]]' ' '|sed 's/ //' |tr '\n' ',' |sed 's/.$//'`"
echo -e ${TEMP}|tr '.' \\t >> $FILE
echo -e "\n" >> $FILE
info=`echo -e ${TEMP}` |tr '.' '|' |sed 's/,$//'
echo -e "bios|$info" >> $data
exit 0
