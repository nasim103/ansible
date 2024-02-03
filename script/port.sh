#!/bin/bash

HOSTNAME=`hostname -s`
data="/tmp/$HOSTNAME-data.txt"
file="/tmp/$HOSTNAME-port.txt"
echo -e "Protocol\tLocal Address\tForeign Address\tState" > $file

portinfo=""
certinfo=`echo -e "\nHostname\tPort\tProtocol\tCipher\tSubject\tIssuer\tStart Time\tEnd Time"`
netstat -antu | sed '1,2d' | (while read LINE
do
        portinfo=$LINE
		# Can't remember why we ignore established connections
		if [[ $LINE != *"ESTABLISHED"* ]]; then
        	protocol=`echo $LINE | tr -s '[[:blank:]]' ',' | awk -F, '{print $1}'`
            localaddr=`echo $LINE | tr -s '[[:blank:]]' ',' | awk -F, '{print $4}'`
            foreignaddr=`echo $LINE | tr -s '[[:blank:]]' ',' | awk -F, '{print $5}'`
            state=`echo $LINE | tr -s '[[:blank:]]' ',' | awk -F, '{print $6}'`
            echo "portinfo|$protocol|$localaddr|$foreignaddr|$state" >> $data
			echo -e "$protocol\t$localaddr\t$foreignaddr\t$state" >> $file
			# Maybe have this print out so we can add it to the excel doc later

			if [[ $state == "LISTEN" ]]; then
				protocol=`echo $LINE | awk -F' ' '{print $1}'`
				if [[ $protocol != *"6"* ]]; then
					#dest=`echo $LINE | awk -F' ' '{print $5}'`
					dest=`echo $LINE | awk -F' ' '{print $4}'`
					hostname=`echo $dest | awk -F':' '{print $1}'`
					port=`echo $dest | awk -F':' '{print $2}'`
					if [[ $port != "*" ]]; then
						certInfo=`echo "Q" | timeout -s SIGINT 10s openssl s_client -connect $hostname:$port 2>/dev/null`
						if [[ $? == 124 ]]; then
							echo -e "certs|$HOSTNAME|$port||||||" >> $data
							certinfo=`echo -e "$certinfo\n$hostname\t$port\t\t\t\t\t\t"`
							continue
						fi

                        certProtocol=`echo $certInfo | grep -o "Protocol : .* Cipher" | awk -F':' '{print $2}' | sed 's/Cipher//' | tr -s " "`
                        certCipher=`echo $certInfo | grep -o "Cipher : .* Session-ID" | awk -F':' '{print $2}' | sed 's/Session-ID//' | tr -s " "`

						moreCertInfo=`echo "Q" | openssl s_client -connect $hostname:$port 2>/dev/null | openssl x509 -subject -issuer -startdate -enddate 2>/dev/null`
						if [[ $? == 0 ]]; then
							subject=`echo $moreCertInfo | grep -o "subject= .* issuer=" | awk -F' ' '{print $2}'`
							issuer=`echo $moreCertInfo | grep -o "issuer= .* notBefore" | awk -F' ' '{print $2}'`
							starttime=`echo $moreCertInfo | grep -o "notBefore=.* notAfter" | sed 's/notBefore=//' | sed 's/notAfter//'`
							endtime=`echo $moreCertInfo | grep -o "notAfter=.* -----BEGIN" | sed 's/notAfter=//' | sed 's/-----BEGIN//'`
							echo "certinfo|$hostname|$port|$certProtocol|$certCipher|$subject|$issuer|$starttime|$endtime" >> $data
							certinfo=`echo -e "$certinfo\n$hostname\t$port\t$certProtocol\t$certCipher\t$subject\t$issuer\t$starttime\t$endtime"`
						else
							echo -e "certinfo|$hostname|$port|$certProtocol|$certCipher||||" >> $data
							certinfo=`echo -e "$certinfo\n$hostname\t$port\t$certProtocol\t$certCipher\t\t\t\t"`
						fi
					fi
				fi
			fi
		fi
done

echo -e "$certinfo" >> $file)
exit 0
