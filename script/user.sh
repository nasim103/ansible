#! /bin/bash
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-users.txt"
data="/tmp/$HOSTNAME-data.txt"
echo -e "Group Name\tFull Name\tName\tUID\tExpiration Date\tLast Change" > $FILE
pr -l 1 /etc/passwd| while read LINE
do
  name=`echo ${LINE}|cut -d ':' -f1`
  uid=`echo ${LINE} |cut -d ':' -f3`
  gid=`echo ${LINE} |cut -d ':' -f4`
  #pw-expire=`sudo chage -l $name |grep "Password expires"|cut -d ':' -f2`
  #pw-change=`sudo chage -l $name |grep "Last password change"|cut -d ':' -f2`
   last_change=`sudo chage -l $name | grep "Last" | cut -d ':' -f2`
   expiration=`sudo chage -l $name | grep "Password expires" | cut -d ':' -f2`

  groupname=`cat /etc/group | grep "\<$gid\>" | cut -d ':' -f1`
  echo -e "$groupname\t$name\t$name\t$uid\t$last_change\t$expiration" >> $FILE
  if [ $expiration = "never" ]; then
      expiration=""
  fi
  echo -e "user|$name|$uid|$expiration" >> $data
done
