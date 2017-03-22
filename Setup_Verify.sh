#!/bin/bash

ZONE=$1
SITENAME=$2
COMMAND_LIST=`cat /home/jioadm/files/COMMAND_LIST_$ZONE.TXT`
if [ $# -lt 2 ]; then
echo "Format:  sh Remote_Run.sh DS/EMS SITE_CODE 2>/dev/null"
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
  #      echo " Checking under process... "
for IP in $IP_LIST
        do
                IPADR=`echo "$IP" | awk -F"|" '{print $2}'`;
                HOST_NAME=`echo "$IP" | awk -F"|" '{print $1}'`;

#        echo -e "Checking on $IP \n" >> /home/jioadm/logs/$ZONE-$DATE
	for COMMAND in $COMMAND_LIST
		do
			echo $COMMAND_LIST >> /home/jioadm/logs/$ZONE-$SITENAME-$DATE
			echo -e $HOST_NAME "," $IPADR "," $COMMAND "," $(ssh $HOST_NAME "$COMMAND") >> /home/jioadm/logs/$ZONE-$SITENAME-$DATE
		done
#echo -e "-----------------------Done----------------------------------- \n" >> /home/jioadm/logs/$ZONE-$DATE
done
sed -e "s/^M/\n/g" /home/jioadm/logs/$ZONE-$SITENAME-$DATE > /home/jioadm/logs/$ZONE-$SITENAME-$DATE.csv
less /home/jioadm/logs/$ZONE-$SITENAME-$DATE.csv
rm /home/jioadm/logs/$ZONE-$SITENAME-$DATE
#rm /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR
#echo 'PFA report' |mailx -s "CDN Daily Report for $DATE" -a /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
