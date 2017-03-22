#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
DPID=$3
SEC=$4
HOUR=$5
DAY=$6
if [ $# -lt 6 ]; then
echo "Format:  sh FetchCDNStats_Hour.sh DS/EMS XXXX DPID >SECONDS HOUR T/Y 2>/dev/null"
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
if [ $ZONE = 'EMS' ]; then
BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0;ipf=0;ips=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1; if(\$1 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$6 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$7; tt=tt+\$10; if (\$10>$SEC) i=i+1; if (\$4 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024,ipf,ips,ips*100/(ipf+ips+.0001)}'"
else
BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0;ipf=0;ips=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1; if(\$1 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$6 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$7; tt=tt+\$10; if (\$10>$SEC) i=i+1; if (\$4 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024,ipf,ips,ips*100/(ipf+ips+.0001)}'"
fi
#BUFFER="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /$HOUR:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-5) ~ /[0-9].[0-9]/) t=\$(NF-5); else t=\$(NF-6); tt=tt+t; if (t>$SEC) i=i+1; if (\$6==\"HIT\") k=k+1; else l=l+1; t=0}} END {print i,\",\",j,\",\",i*100/(j+.0001),\",\",k,\",\",l,\",\",k*100/(k+l+.0001),\",\",x,\",\",y,\",\",x*100/(x+y+.0001),\",\",tt/(j+.0001),\",\",td/1024/1024/1024}'"
#BUFFER1="awk 'BEGIN {i=0;j=0;k=0;l=0;x=0;y=0;d=0;tt=0;td=0;t=0} {if (\$4 ~ /19:[0-9][0-9]:[0-9][0-9]/) {j=j+1;if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) x=x+1; else y=y+1; if(\$10 ~ /^[0-9][0-9][0-9]$/) d=\$11; else d=\$12; td=td+d; if(\$(NF-5) ~ /[0-9].[0-9]/) t=\$(NF-5); else t=\$(NF-6); tt=tt+t; if (t>20) i=i+1; if (\$6=="HIT") k=k+1; else l=l+1; t=0}} END {print i,",",j,",",i*100/j,",",k,",",l,",",k*100/(k+l),",",x,",",y,",",x*100/(x+y),",",tt/j,",",td/1024/1024/1024}'"
#BUFFER="awk '{if(\$(NF-5) ~ /[0-9].[0-9]/) {print \$(NF-5)} else print \$(NF-6)}'| awk '\$1>15'"
#BUFFER1="awk '{if(\$(NF-5) ~ /[0-9].[0-9]/) {print \$(NF-5)} else print \$(NF-6)}'| awk '\$1>20'"
echo "HOSTNAME,IP,Req took>$SEC Seconds,Total Req,% of Req took>$SEC Seconds,HITS,MISS,HIT %,Success,Failures,Success %,Avg Resp time,Data Cons in GB,IPv4, IPv6, IPv6 %"
#echo "HOSTNAME,IP,Buffering Req,Total Req,Buffering %,HITS,MISS,HIT %,Success,Failures,Success %,Avg Response time,Data Consumption in GB" >> /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR
#echo "HOSTNAME,IP,Buffering Requests,Total Requests,Buffering Percentage,No of HITS,No of Miss,HIT Percentage,Total Success,Total Failures,Success Percentage,Avg Response time,Total Data Consumption in GB" >> /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR
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

    #    echo -e "Checking on $IP \n"

if [ $DAY = 'T' ]; then
DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log | $BUFFER")
else
DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE | $BUFFER")
fi
#DATA7=$(sshpass -p $PASS $SSH $USR@$IPADR "cat $LOGFILE-$DATE |$BUFFER")
#echo $IPADR","$HOST_NAME","$DATA1 >> /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR
echo $HOST_NAME","$IPADR","$DATA1
#echo $IP"|"$DATA4"|"$DATA7 >> CDN_STATS_$ZONE-$SITENAME-$DPIDNAME-$DATE
#echo "-----------------------Done-----------------------------------"
done
#sed -e "s///g" /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR > /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR.csv
#sed -e "s/,/ /g" CDN_STATS_$ZONE-$SITENAME-$DPIDNAME1-$DATE > CDN_STATS_$ZONE-$SITENAME-$DPIDNAME-$DATE
#sed -e "s/|/,/g" CDN_STATS_$ZONE-$SITENAME-$DPIDNAME-$DATE > CDN_STATS_$ZONE-$SITENAME-$DPIDNAME-$DATE.csv
#rm /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE-$HOUR
#echo 'PFA report' |mailx -s "CDN Daily Report for $DATE" -a /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/CDN_STATS_$ZONE-$SITENAME-$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
