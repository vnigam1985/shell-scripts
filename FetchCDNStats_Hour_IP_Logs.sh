#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
DPID=$3
SEC=$4
HOUR=$5
USER_IP=$6
DAY=$7
rm /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log
if [ $# -lt 6 ]; then
echo "Format:  sh FetchCDNStats_Hour_IP_Log.sh DS/EMS XXXX DPID >SECONDS HOUR IP T/Y 2>/dev/null"
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
if [ $DAY = 'T' ]; then
DATE1=$(date +%d/%b/%Y)
else
DATE1=$(date +%d/%b/%Y -d "Yesterday")
fi
#DATE=$(date -d "-1 day" +%Y%m%d)
DATE=$(date +%Y%m%d)
USR='jioadm'
if [ $ZONE = 'EMS' ]; then
BUFFER="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-5) ~ /[0-9].[0-9]/) t=\$(NF-5); else t=\$(NF-6); tt=tt+t; if (t>$SEC) i=i+1; if (\$6==\"HIT\") k=k+1; else l=l+1; t=0}} END {print \$1, i,\",\",j,\",\",i*100/(j+.0001),\",\",k,\",\",l,\",\",k*100/(k+l+.0001),\",\",x,\",\",y,\",\",x*100/(x+y+.0001),\",\",tt/(j+.0001),\",\",td/1024/1024/1024}'"
else
BUFFER="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-4) ~ /[0-9].[0-9]/) t=\$(NF-4); else t=\$(NF-5); tt=tt+t; if (t>$SEC) i=i+1; if (\$6==\"HIT\") k=k+1; else l=l+1; t=0}} END {print i,\",\",j,\",\",i*100/(j+.0001),\",\",k,\",\",l,\",\",k*100/(k+l+.0001),\",\",x,\",\",y,\",\",x*100/(x+y+.0001),\",\",tt/(j+.0001),\",\",td/1024/1024/1024}'"
fi
#BUFFER="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-5) ~ /[0-9].[0-9]/) t=\$(NF-5); else t=\$(NF-6); tt=tt+t; if (t>$SEC) i=i+1; if (\$6==\"HIT\") k=k+1; else l=l+1; t=0}} END {print i,\",\",j,\",\",i*100/(j+.0001),\",\",k,\",\",l,\",\",k*100/(k+l+.0001),\",\",x,\",\",y,\",\",x*100/(x+y+.0001),\",\",tt/(j+.0001),\",\",td/1024/1024/1024}'"
#IP_LOG="awk '{a=substr(\$4,2,20); b=substr(\$0,match(\$0,/\/H/)+1,15); if (\$10 ~ /^[0-9][0-9][0-9]$/) {if(\$(NF-5) ~ /[0-9].[0-9]/) print a,\$6,b,\$10,\$11, \$(NF-5); else print a,\$6,b,\$10,\$11,\$(NF-6);} else {if(\$(NF-5) ~ /[0-9].[0-9]/) print a,\$6,b,\$10,\$12, \$(NF-5); else print a,\$6,b,\$10,\$12,\$(NF-6);}}'"
#BUFFER1="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /19:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-5) ~ /[0-9].[0-9]/) t=\$(NF-5); else t=\$(NF-6); tt=tt+t; if (t>20) i=i+1; if (\$6=="HIT") k=k+1; else l=l+1; t=0}} END {print i,",",j,",",i*100/j,",",k,",",l,",",k*100/(k+l),",",x,",",y,",",x*100/(x+y),",",tt/j,",",td/1024/1024/1024}'"
#IP_LOG="awk '{a=substr(\$4,2,20); b=substr(\$0,match(\$0,/cdn.jio.com/)+12,match(\$0,/HTTP/)-match(\$0,/cdn.jio.com/)-12); if (\$10 ~ /^[0-9][0-9][0-9]$/) {if(\$(NF-5) ~ /[0-9].[0-9]/) print a,\$6,b,\$10,\$11, \$(NF-5); else print a,\$6,b,\$10,\$11,\$(NF-6);} else {if(\$(NF-5) ~ /[0-9].[0-9]/) print a,\$6,b,\$10,\$12, \$(NF-5); else print a,\$6,b,\$10,\$12,\$(NF-6);}}'"
#IP_LOG="awk 'BEGIN {print \"Time,HIT or MISS,Request,ResCode,ChunkSize,ResTime\";}{a=substr(\$4,2,20); b=substr(\$0,match(\$0,/cdn.jio.com/)+12,match(\$0,/HTTP/)-match(\$0,/cdn.jio.com/)-13); if (\$10 ~ /^[0-9][0-9][0-9]$/) {if(\$(NF-5) ~ /[0-9].[0-9]/) arr[a,\$6,b,\$10,\$11, \$(NF-5)]++; else arr[a,\$6,b,\$10,\$11,\$(NF-6)]++;} else {if(\$(NF-5) ~ /[0-9].[0-9]/) arr[a,\$6,b,\$10,\$12, \$(NF-5)]++; else arr[a,\$6,b,\$10,\$12,\$(NF-6)]++;}} END {for (var in arr) print var arr[var]}'"
IP_LOG="awk 'BEGIN {print \"Time,HIT or MISS,Request,ResCode,ChunkSize,ResTime\";}{a=substr(\$4,2,20); b=substr(\$0,match(\$0,/cdn.jio.com/)+12,match(\$0,/HTTP/)-match(\$0,/cdn.jio.com/)-13); if (\$10 ~ /^[0-9][0-9][0-9]$/) {if(\$(NF-5) ~ /[0-9].[0-9]/) arr[a,\$6,b,\$10,\$11, \$(NF-5)]++; else arr[a,\$6,b,\$10,\$11,\$(NF-6)]++;} else {if(\$(NF-5) ~ /[0-9].[0-9]/) arr[a,\$6,b,\$10,\$12, \$(NF-5)]++; else arr[a,\$6,b,\$10,\$12,\$(NF-6)]++;}} END {for (var in arr) print var arr[var]}'"
#echo "HOSTNAME,IP,Buffering Requests,Total Requests,Buffering Percentage,No of HITS,No of Miss,HIT Percentage,Total Success,Total Failures,Success Percentage,Avg Response time,Total Data Consumption in GB" >> /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR
#echo "HOSTNAME,IP,Buffering Req,Total Req,Buffering %,HITS,MISS,HIT %,Success,Failures,Success %,Avg Response time,Data Consumption in GB"
function PSWD_LIST()
        {

				PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
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
> /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
  #      echo " Checking under process... "
        for IP in $IP_LIST
        do
                IPADR=`echo "$IP" | awk -F"|" '{print $2}'`;
                HOST_NAME=`echo "$IP" | awk -F"|" '{print $1}'`;
                PSWD_LIST;
                PASS=$PSWD

        echo -e "Checking on $HOST_NAME"  >> /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
#$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG >> /tmp/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log")
if [ $DAY = 'T' ]; then
echo -e $(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID.log | grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG") >> /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
else
echo -e $(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID.log-$DATE | grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG") >> /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
fi

#echo $DATA
#$(sshpass -p $PASS scp jioadm@$IPADR:/tmp/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log /home/jioadm/logs/)
#sshpass -p $PASS scp jioadm@$IPADR:/tmp/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log /home/jioadm/logs/
#$(sshpass -p $PASS $SSH $USR@$IPADR "rm /tmp/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log;")
#cat /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log
#echo $(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | grep -v ' 503 '|grep $DATE1:$HOUR  | grep $USER_IP | $IP_LOG")
#echo $DATA1
#echo $IPADR","$HOST_NAME","$DATA1
#echo $IP"|"$DATA4"|"$DATA7 >> CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE
echo "-----------------------Done-----------------------------------"
done
sed -e "s//\n/g" /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR > /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log
less /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log
rm /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
#sed -e "s/\W/ /g" /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR.log > /home/jioadm/logs/$HOST_NAME_$SITENAME-$DPID-$DATE-$HOUR
#sed -e "s/,/ /g" CDN_EMS_Stats_$SITENAME-$DPIDNAME1-$DATE > CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE
#sed -e "s/|/,/g" CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE > CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv
#rm /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE-$HOUR
#echo 'PFA report' |mailx -s "CDN Daily Report for $DATE" -a /home/jioadm/reports/CDN_EMS_Stats_$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/CDN_EMS_Stats_$SITENAME-$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
