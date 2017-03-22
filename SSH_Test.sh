#!/bin/bash

ZONE=$1
SITENAME=$2
#COMMAND=$3
if [ $# -lt 2 ]; then
echo "Format:  sh SSH_Test.sh DS/EMS SITE_CODE"
echo "SITE_CODE above is SiteCode like mum/bhpl/amdb/ptna/ngpr/chnn/koch/jpur/hdbd/agra/lckn/klkt/ldhn/dlhi/bglr or all in case of all site stats"
echo "Type the exact command at place of COMMAND in double quotes"
exit
fi
if [ $SITENAME = 'all' ]; then
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT`
else
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT |grep ${SITENAME,,}`
fi
#DATE=$(date -d "-1 day" +%Y%m%d)
DATE=$(date +%Y%m%d)
USR='jioadm'
  #      echo " Checking under process... "
for IP in $IP_LIST
        do
                IPADR=`echo "$IP" | awk -F"|" '{print $2}'`;
                HOST_NAME=`echo "$IP" | awk -F"|" '{print $1}'`;

#        echo -e "Checking on $IP \n" >> /home/jioadm/logs/$ZONE-$DATE
#$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG >> /tmp/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log")
OP=$(ssh $HOST_NAME "tail -1 /var/log/nginx/access_12053.log") #>> /home/jioadm/logs/SSH_Test-$ZONE-$SITENAME-$DATE.log
if [ $? = 0 ]; then
	echo "Do nothing"
else
	for i in 1 2 3
	do
		sleep 10
		OPFOR=$(ssh $HOST_NAME "tail -1 /var/log/nginx/access_12053.log")# >> /home/jioadm/logs/SSH_Test-$ZONE-$SITENAME-$DATE.log
		if [ $? != 0 ] && [ $i = 3 ]; then
		echo "SSH Failed $i"
		echo "SSH failed on $HOST_NAME, Kindly take quick action." |mailx -s "SSH failed on $HOST_NAME ($IPADR)" -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com,RJIL.NOCSASOL1Support@ril.com
		fi
	done
fi
#echo -e $(sshpass -p $PASS $SSH $USR@$IPADR "ps -aef | egrep '$PROCESS_NAME'") "\n" >> /home/jioadm/logs/$ZONE-$DATE

#echo -e "-----------------------Done----------------------------------- \n" >> /home/jioadm/logs/$ZONE-$DATE
done
#sed -e "s/^M/\n/g" /home/jioadm/logs/$ZONE-$DATE > /home/jioadm/logs/$ZONE-$DATE.log
#less /home/jioadm/logs/SSH_Test-$ZONE-$SITENAME-$DATE.log
#rm /home/jioadm/logs/$ZONE-$DATE
#rm /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR
#echo 'PFA report' |mailx -s "CDN Daily Report for $DATE" -a /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
