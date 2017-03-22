#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
DPID=$3
SEC=$4
HOUR=$5
USER_IP=$6
DAY=$7
if [ $# -lt 6 ]; then
echo "Format:  sh FetchCDNStats_Hour_IP.sh DS/EMS XXXX DPID >SECONDS HOUR IP Y/T 2>/dev/null"
echo "XXX above is SiteCode like mum/bhpl/amdb/ptna/ngpr/chnn/koch/jpur/hdbd/agra/lckn/klkt/ldhn/dlhi/bglr or all in case of all site stats"
echo ">SECONDS above is response time greater than how many seconds should be considered in this report"
echo "HOUR above is the hour you want to fetch the report for"
exit
fi
if [ $SITENAME = 'all' ]; then
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT`
else
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT |grep $SITENAME`
fi
#DATE=$(date -d "-1 day" +%Y%m%d)
DATE=$(date +%Y%m%d)
USR='jioadm'
if [ $DAY = 'Y' ]; then
DATE1=$(date +%Y%m%d)
else
DATE1=$(date +%d/%b/%Y -d "Yesterday")
fi
if [ $ZONE = 'EMS' ]; then
BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;tt=0;td=0;} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1; if(\$1 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$6 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$7; tt=tt+\$10; if (\$10>$SEC) i=i+1; if (\$4 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024}'"
else
BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;tt=0;td=0;} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1; if(\$2 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$7 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$8; tt=tt+\$11; if (\$11>$SEC) i=i+1; if (\$5 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024}'"
fi
echo "Buffering Req,Total Req,Buffering %,HITS,MISS,HIT %,Success,Failures,Success %,Avg Response time,Data Consumption in GB"
function PSWD_LIST()
        {

#                                echo "Password" "Verification" " PROGRESS "
                              #  PSW_LIST=`cd /opt/CARKaim/sdk;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMJiosaso -p Query="username=jiouser;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
				PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
				#PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=10.139.33.19" -p RequiredProps=UserName -o Password`
                                for p in $PSW_LIST
                                do
                                sshpass -p $p $SSH $USR@$IPADR "exit" 2> /dev/null 1> /dev/null
                                                if [ $? = 0 ]; then
                                                PSWD=$p
 #                                               echo "Password Verification SUCCESS"
                                                break
                                                fi
                                                done
                                                if [ -z "$PSWD" ];then
                                                echo "Login" "Permission DENIED"
                                                fi
        }

sleep 1
  #      echo " Checking under process... "
        for IP in $IP_LIST
        do
                IPADR=`echo "$IP" | awk -F"|" '{print $2}'`;
                HOST_NAME=`echo "$IP" | awk -F"|" '{print $1}'`;
                PSWD_LIST;
                PASS=$PSWD

        echo -e "Checking on $IP \n"
if [ $DAY = 'T' ]; then
DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log |grep $USER_IP | $BUFFER")
else
DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE1 |grep $USER_IP | $BUFFER")
fi

#DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log |grep $USER_IP | $BUFFER")
#DATA7=$(sshpass -p $PASS $SSH $USR@$IPADR "cat $LOGFILE-$DATE |$BUFFER")
#echo $IPADR","$HOST_NAME","$DATA1 >> /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR-$USER_IP
#DATA=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | grep -v ' 503 '|grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG >> /tmp/script.log; cat /tmp/script.log;scp username@remote:/file/to/send /where/to/put")
#echo ${DATA}
#echo $(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | grep -v ' 503 '|grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG")
echo $DATA1
#echo $IPADR","$HOST_NAME","$DATA1
#echo $IP"|"$DATA4"|"$DATA7 >> CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE
echo "-----------------------Done-----------------------------------"
done
#sed -e "s///g" /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR > /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR.csv
#sed -e "s/,/ /g" CDN_EMS_Stats_$SITENAME-$DPIDNAME1-$DATE > CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE
#sed -e "s/|/,/g" CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE > CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv
#rm /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR
#echo 'PFA report' |mailx -s "CDN Daily Report for $DATE" -a /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
