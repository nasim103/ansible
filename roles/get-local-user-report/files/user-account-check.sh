#!/bin/bash

HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-users.txt"

#echo "$HOSTNAME Users" > $FILE
#echo -e "Group Name\tGECOS\tName\tUID\tExpiration Date\tLast Change" >> $FILE
pr -l 1 /etc/passwd | while read LINE
do
    username=`echo ${LINE} | cut -d ':' -f1`

    sudo_access=''
    sudo_roles=''
    sudo_commands=''
    access=`sudo -l -U $username | grep 'Matching' 2>/dev/null`
    if [[ $? == 0 ]];then
        sudo_access='Yes'
        sudo_roles=`sudo -l -U $username | awk '/Matching/{f=1;next} /User/{f=0} f'`
        sudo_commands=`sudo -l -U $username | sed -n -e '/User/,$p' | tail -n +2 | tr '\n' ',' | sed 's/.$//'`
    else
        sudo_access='No'
        sudo_roles='N/A'
        sudo_commands='N/A'
    fi

    lastLog=`last -R -n 1 $username | awk '/still logged in/ {print $3,$4,$5,$6}'`
    if [[ $lastLog != *':'* ]];then
        lastLog="N/A"
    fi

    locked=`sudo passwd -S $username`
    if [[ $locked = *"Password locked."* ]];then
        locked=true
    else
        locked=false
    fi

    gecos=`echo ${LINE} | cut -d ':' -f5`
    uid=`echo ${LINE} | cut -d ':' -f3`
    gid=`echo ${LINE} | cut -d ':' -f4`
    shell=`echo ${LINE} | cut -d ':' -f7`

    last_change=`chage -l $username | grep "Last" | cut -d ':' -f2`
    expiration=`chage -l $username | grep "Password expires" | cut -d ':' -f2`

    #group=`cat /etc/group | grep "\<$gid\>" | cut -d ':' -f1`
    groups=`grep $username /etc/group | awk -F':' '{print $1}' | tr '\n' ',' | sed 's/.$//'`

    echo -e "$HOSTNAME;$username;$uid;$gecos;$groups;$shell;$expiration;$last_change;$lastLog;$locked;$sudo_access;$sudo_roles;$sudo_commands" >> $FILE
done

