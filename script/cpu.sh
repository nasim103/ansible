#!/bin/bash
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-cpuinfo.txt"
data="/tmp/$HOSTNAME-data.txt"
echo "CPU" >> $FILE
echo -e "Device ID\tManufacturer\tModel\tL2 Cache Size (KB)\tSpeed (MHz)\tArchitecture" >> $FILE
countinterval=`cat /proc/cpuinfo |grep "processor" |wc -l`
for (( i=1; i<=countinterval; i++ )); do
    processor=`cat /proc/cpuinfo | grep -m$i "processor" | awk -F':' '{print $2}'| tail -1 | sed 's/ //'`
    model=`cat /proc/cpuinfo | grep -m$i "model name" | awk -F':' '{print $2}'| tail -1 | sed 's/ //'`
    vendor=`cat /proc/cpuinfo | grep -m$i "vendor_id" | awk -F':' '{print $2}'| tail -1 | sed 's/ //'`
    cpuspeed=`cat /proc/cpuinfo | grep -m$i "cpu MHz" | awk -F':' '{print $2}'| tail -1 | sed 's/ //'`
    l2cache=`lscpu | grep "L2 cache" | awk -F: '{print $2}' | tr -s '[[:blank:]]' ' ' | sed 's/ //' | sed 's/[^0-9]*//g'`
    architecture=`lscpu | grep "Architecture" | awk -F: '{print $2}' | tr -s '[[:blank:]]' ' ' | sed 's/ //'`
    echo -e "cpu$processor\t$vendor\t$model\t$l2cache\t$cpuspeed\t$architecture" >> $FILE
    echo "cpu|cpu$processor|$vendor|$model|$l2cache|$cpuspeed|$architecture" >> $data
done

echo -e "\n" >> /$FILE
exit 0
