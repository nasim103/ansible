#!/bin/bash

HOSTNAME=`hostname -s` # Hostname of server
SYSTEM=`uname -s` # System of the server i.e. Linux
IP=${1} # IP of the server
DOMAIN=${3} # Domain the server is on
MEMORY=`vmstat -s | grep "total memory" | awk '{print $1}' | tr -s '[[:blank:]]' ' ' | sed 's/ //'` # The total amount of RAM
VIRTUAL=${2} # The total amount of virtual memory
PROCESSORS=`lscpu | grep "Socket(s):" | awk '{print $2}'` # The number of processors
CORES=`lscpu | grep "Core(s)" | awk '{print $4}'`  # The number of cores in each processor
LOGICAL=`lscpu | grep -m 1 "CPU(s):" | awk '{print $2}'`
#DISK=`sudo /sbin/pvdisplay | grep "PV Size" | awk '{print $3}'` # The total size of the disk
FILE="/tmp/$HOSTNAME-server-overview.txt" # Where the buildbook will be stored

echo "Server Overview" > $FILE
echo -e "OS Name\t$SYSTEM" >> $FILE

# Get the version of the OS
OS_VERSION=`sed -e '$!d' /etc/*-release`
echo -e "OS Version\\t$OS_VERSION" >> $FILE

echo -e "IP Address\\t$IP" >> $FILE

# Get the last boot time
REBOOT=`who -b | awk '{print $3,$4}'`
echo -e "Last Boot Time\t$REBOOT" >> $FILE

echo -e "Machine Domain\t$DOMAIN" >> $FILE
echo -e "Domain Role " >> $FILE

for i in 1 2
do
   MEMORY=$(($MEMORY / 1024))
done
echo -e "Installed Memory (GB)\\t$(($MEMORY + 1))" >> $FILE

echo -e 'Virtual Memory (GB)\\t$((("$VIRTUAL / 1024) + 1"))' >> $FILE
echo -e "Number of Socketed Processors\t$PROCESSORS" >> $FILE
echo -e "Number of Cores\t$CORES" >> $FILE
echo -e "Number of Logical Processors\\t$LOGICAL" >> $FILE

# Grab all of the disk information
DIR="/sys/block"
for DEV in `ls -1d /sys/block/*/device/*disk*/ | awk -F\/ '{print $4}'`; do
  if [ -d $DIR/$DEV ]; then
    REMOVABLE=`cat $DIR/$DEV/removable`
    if (( $REMOVABLE == 0 )); then
      SIZE=`cat $DIR/$DEV/size`
      GB=$((($SIZE*512)/1024/1024/1024))
      TOTAL=$(($TOTAL+$GB))
    fi
  fi
done
DISK=$TOTAL
echo -e "Total Disk Space (GB)\t$DISK" >> $FILE

TIMESTAMP=`date +'%b %d,%Y %r'`
echo "$TIMESTAMP" >> $FILE
