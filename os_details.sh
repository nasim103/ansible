#! /bin/bash
#Author=Nasim Ahmad
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-os-info.txt"
data="/tmp/$HOSTNAME-osdata.txt"

PRODUCT=`uname -s`
KERNEL=`uname -srnv`
VERSION=`uname -r`
BIT_SIZE=`uname -m`
#INSTALL_DATE=`uname -v | sed 's/#1 SMP //'`

echo "OS Details" >> $FILE
echo -e "Product\tVersion\tKernel Bit Size\tKernel Version" >> $FILE
echo -e "$PRODUCT\t$VERSION\t$BIT_SIZE\t$KERNEL" >> $FILE
echo "os|$PRODUCT|$VERSION|$BIT_SIZE|$KERNEL" >> $data