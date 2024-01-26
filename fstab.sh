#! /bin/bash
HOSTNAME=`hostname -s`
FILE="/tmp/$HOSTNAME-fstab-info.txt"
echo "FSTAB" >> $FILE
echo -e "Device (fs_spec)\tMount Point (fs_file)\tFilesystem (fs_vfstype)\tOptions (fs_mntops)\tDump (fs_freq)\tMount Order (fs_passno)" >> $FILE
column -t /etc/fstab -o ',' | while read LINE
 do
  find_hash=`echo $LINE | grep "^#"`
   if [ $? != 0 ]; then
     data=`echo $LINE`
        fs_spec=`echo $LINE | awk -F',' '{print $1}' | tr -d '[:space:]'`
        fs_file=`echo $LINE | awk -F',' '{print $2}' | tr -d '[:space:]'`
        fs_vfstype=`echo $LINE | awk -F',' '{print $3}' | tr -d '[:space:]'`
        fs_mntops=`echo $LINE | awk -F',' '{print $4}' | tr -d '[:space:]'`
        fs_freq=`echo $LINE | awk -F',' '{print $5}' | tr -d '[:space:]'`
        fs_passno=`echo $LINE | awk -F',' '{print $6}' | tr -d '[:space:]'`
        echo -e "$fs_spec\t$fs_file\t$fs_vfstype\t$fs_mntops\t$fs_freq\t$fs_passno" >> $FILE
    fi
 done
  echo -e "\n" >> $FILE
  exit 0