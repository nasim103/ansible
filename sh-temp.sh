#! /bin/bash
read -p "Enater the script name" name
touch /home/linuxtechiee/Documents/mycode/$name.sh
echo -e "#! /bin/bash" >> /home/linuxtechiee/Documents/mycode/$name.sh
echo -e "Date=`date`" >> /home/linuxtechiee/Documents/mycode/$name.sh
echo -e "#Author=Nasim Ahmad" >> /home/linuxtechiee/Documents/mycode/$name.sh
echo -e "HOSTNAME=hostname -s" >> /home/linuxtechiee/Documents/mycode/$name.sh
echo -e 'FILE="/tmp/$HOSTNAME-$name-info.txt"' >> /home/linuxtechiee/Documents/mycode/$name.sh
