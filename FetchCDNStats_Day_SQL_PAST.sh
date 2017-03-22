#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
DPID=$3
SEC=$4
PAST_DATE=$5
rm /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID*
cat /dev/null > /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID.sql
if [ $# -lt 5 ]; then
echo "Format:  sh FetchCDNStats_Day.sh DS/EMS XXX DPID >SECONDS"
echo "XXX above is SiteCode like mum/bhpl/amdb/ptna/ngpr/chnn/koch/jpur/hdbd/agra/lckn/klkt/ldhn/dlhi/bglr or all in case of all site stats"
echo ">SECONDS above is response time greater than how many seconds should be considered in this report"
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
FILTER="awk -v HN=$HOST_NAME -v IP=$IPADR -v APP_ID=$DPID -v Z=$ZONE 'BEGIN{OFS=\",\";U=\"0\";} {tot[substr(\$4,2,16)]++;if(length(\$1) > 15) ipv6[substr(\$4,2,16)]++; else ipv4[substr(\$4,2,16)]++; if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) success[substr(\$4,2,16)]++; else failure[substr(\$4,2,16)]++; if(\$10 ~ /^[0-9][0-9][0-9]$/) data[substr(\$4,2,16)]+=\$11; else data[substr(\$4,2,16)]+=\$12; if(\$(NF-5) ~ /[0-9].[0-9]/) {time[substr(\$4,2,16)]+=\$(NF-5); if (\$(NF-5)>$SEC) buff[substr(\$4,2,16)]++} else {time[substr(\$4,2,16)]+=\$(NF-6);if (\$(NF-6)>$SEC) buff[substr(\$4,2,16)]++;}; if (\$6==\"HIT\") hit[substr(\$4,2,16)]++; else miss[substr(\$4,2,16)]++;} END {for (var in tot) print \"STR_TO_DATE( \x27\" substr(var,1,11) \"\x27\", \"\x27\" \"%d/%b/%Y\" \"\x27 )\",  \"\42\" substr(var,13,16)U \"\42\", APP_ID, \"\42\" Z \"\42\", \"\42\" HN \"\42\", \"\42\" IP \"\42\", buff[var]+1,  tot[var]+2, buff[var]*100/(tot[var]+.001),  hit[var]+1, miss[var]+1, hit[var]*100/(tot[var]+.0001), success[var]+1, failure[var]+1, success[var]*100/(tot[var]+.001), time[var]/(tot[var]+.0001), data[var] ,  ipv6[var]+1, ipv4[var]+1, ipv6[var]*100/(tot[var]+.0001), \"VISHAL\";}'"
#BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;tt=0;td=0;ipf=0;ips=0} {{j=j+1; if(\$1 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$7 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$8; tt=tt+\$11; if (\$11>$SEC) i=i+1; if (\$5 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024,ipf,ips,ips*100/(ipf+ips+.0001)}'"
else
BUFFER="awk 'BEGIN {FS=\"|\";OFS=\",\";i=0;j=0;k=0;l=0;x=0;y=0;tt=0;td=0;ipf=0;ips=0} {{j=j+1; if(\$2 ~ /[0-9][0-9][0-9][0-9]:/) ips=ips+1; else ipf=ipf+1; if (\$7 ~ /2[0-9][0-9]/) x=x+1; else y=y+1; td=td+\$8; tt=tt+\$11; if (\$11>$SEC) i=i+1; if (\$5 ~ /HIT/) k=k+1; else l=l+1;}} END {print i,j,i*100/(j+.0001),k,l,k*100/(k+l+.0001),x,y,x*100/(x+y+.0001),tt/(j+.0001),td/1024/1024/1024,ipf,ips,ips*100/(ipf+ips+.0001)}'"
fi
#echo "HOSTNAME,IP,Req took>$SEC Seconds,Total Req,% of Req took>$SEC Seconds,HITS,MISS,HIT %,Success,Failures,Success %,Avg Resp time,Data Cons in GB,IPv4,IPv6,IPv6 %" #>> /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE
function PSWD_LIST()
        {

                                echo "Password" "Verification" " PROGRESS "
                              #  PSW_LIST=`cd /opt/CARKaim/sdk;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMJiosaso -p Query="username=jiouser;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
				PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
				#PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=10.139.33.19" -p RequiredProps=UserName -o Password`
                                for p in $PSW_LIST
                                do
                                sshpass -p $p $SSH $USR@$IPADR "exit" 2> /dev/null 1> /dev/null
                                                if [ $? = 0 ]; then
                                                PSWD=$p
                                                echo "Password Verification SUCCESS"
                                                break
                                                fi
                                                done
                                                if [ -z "$PSWD" ];then
                                                echo "Login" "Permission DENIED"
                                                fi
        }

sleep 1
        echo " Checking under process... "
        for IP in $IP_LIST
        do
                IPADR=`echo "$IP" | awk -F"|" '{print $2}'`;
                HOST_NAME=`echo "$IP" | awk -F"|" '{print $1}'`;
                PSWD_LIST;
                PASS=$PSWD

        echo -e "Checking on $IP \n"

DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "zcat /var/log/nginx/access_$DPID\.log-$PAST_DATE\.gz | grep -v ' 503 '| $BUFFER")
if [ $? -ne 0 ]; then
DATA1="0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0"
#echo $DATA1
fi
#DATA7=$(sshpass -p $PASS $SSH $USR@$IPADR "cat $LOGFILE-$DATE |$BUFFER")
echo $HOST_NAME","$IPADR","$DATA1 >> /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE
#echo $IP"|"$DATA4"|"$DATA7 >> $DPIDNAME-$DATE
echo "-----------------------Done-----------------------------------"
DB_HOST="10.137.2.4"
DB_USER="sasorw"
DB_USER_PASSWORD="sasorw@246"
DB_PORT="3306"
DB_DBNAME="sasodb"


checkDbConnection() {
MysqlConnectionStatus=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER --password=$DB_USER_PASSWORD -e "show databases;"|grep -m 1 "$DB_DBNAME")
if [[ $MysqlConnectionStatus != "$DB_DBNAME" ]]
then
        echo
        echo "The DB connection could not be established. Check the database details and try again."
        #sendEmail "Unable to connect database server \"$DB_HOST\""
       # echo
        exit 1
fi
}

echo "INSERT IGNORE INTO SASO_CDN_STATS(DATE,APP_ID,ZONE,HOSTNAME,IP,BUFFERING_REQUESTS,TOTAL_REQUESTS,BUFFERING_PERCENTAGE,TOTAL_HITS,TOTAL_MISS,HIT_PERCENTAGE,TOATAL_SUCCESS,TOTAL_FAILURES,SUCCESS_PERCENTAGE,AVG_RESPONSE_TIME,DATA_CONSUMPTION_IN_GB,IPV4_COUNT,IPV6_COUNT,IPV6_PERCENTAGE) VALUES("\""$PAST_DATE"\""","$DPID",""\""$ZONE"\""",""\""$HOST_NAME"\""",""\""$IPADR"\""","$DATA1);" >> /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID
checkDbConnection
done
sed -e "s///g" /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID > /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID.sql
less /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID.sql
rm /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID
#mysql -h $DB_HOST -u $DB_USER -p$DB_USER_PASSWORD -P $DB_PORT $DB_DBNAME < /tmp/CDN_DAILY_STATS_$ZONE-$SITENAME-$DPID.sql
sed -e "s///g" /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE > /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE.csv
rm /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE
#echo 'PFA report' |mailx -s "CDN Daily Response Time Report from $ZONE for $DATE" -a /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com,deepak12.gupta@ril.com,pratiksha.thuturkar@ril.com
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/$DPIDNAME-$DATE.csv  -r vishal.nigam@ril.com vishal.nigam@ril.com
