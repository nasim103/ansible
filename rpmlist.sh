#!/bin/bash
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-rpmlist.txt"
data="/tmp/$HOSTNAME-data-rpm.txt"

echo -e "Software Name\tVendor\tInstall Date\tVersion\tSize" > $FILE

# This should hopefully not lock down the rpm database in any way
# Hopefully the output is the same
rpms_list=`timeout 3600 rpm -qa --queryformat '%{NAME}|%{VENDOR}|%{INSTALLTIME}|%{VERSION}-%{RELEASE}.%{ARCH}|%{SIZE}\n'`
if [[ $? -eq 124 ]]; then
    exit 1
fi

echo "$rpms_list" | while read package
do
    echo "applications|$package" >> $data
    rpmdatabb=`echo "$package" | sed 's/|/\t/g'`
    echo "$rpmdatabb" >> $FILE
done

#for package in `rpm -qa --last | cut -d ' ' -f 1`
#do
#        rpmdata=`rpm -q --queryformat '%{NAME}|%{VENDOR}|%{INSTALLTIME}|%{VERSION}-%{RELEASE}.%{ARCH}|%{SIZE}\n' $package` #>> $data
#        echo "applications|$rpmdata" >> $data
#        rpmdatabb=`echo "$rpmdata" | sed 's/|/\t/g'`
#        echo "$rpmdatabb" >> $FILE
#done

exit 0