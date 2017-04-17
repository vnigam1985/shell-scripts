#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
DPID=$3
SEC=$4
DAY=$5
DATE1=$(date +%Y%m%d -d "Yesterday")
DATE=$(date +%Y%m%d)
#T_DATE=$(date +%d-1\\\/%b\\\/%Y)
T_DATE=$(date +%d\\\/%b\\\/%Y -d "Yesterday")
USR='jioadm'
DB_HOST="10.137.2.4"
DB_USER="sasorw"
DB_USER_PASSWORD="*******"
DB_PORT="3306"
DB_DBNAME="sasodb"
rm /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE1.sql
rm /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE1
#cat /dev/null > /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql
if [ $# -lt 5 ]; then
echo "Format:  sh FetchCDNStats_Day.sh DS/EMS XXX DPID >SECONDS"
echo "XXX above is SiteCode like mum/bhpl/amdb/ptna/ngpr/chnn/koch/jpur/hdbd/agra/lckn/klkt/ldhn/dlhi/bglr or all in case of all site stats"
echo ">SECONDS above is response time greater than how many seconds should be considered in this report"
#echo "Y/T above is yesterday of today"
exit
fi
if [ $SITENAME = 'all' ]; then
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT`
else
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT |grep $SITENAME`
fi
#DATE=$(date -d "-1 day" +%Y%m%d)
function PSWD_LIST()
        {
         echo "Password" "Verification" " PROGRESS "
	 PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
	#PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=10.139.33.19" -p RequiredProps=UserName -o Password`
         for p in $PSW_LIST
         do
         	#sshpass -p $p $SSH $USR@$IPADR "exit" 2> /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.log 1> /dev/null
         	sshpass -p $p $SSH $USR@$IPADR "exit" 2> /dev/null 1> /dev/null
                if [ $? = 0 ]; then
                	PSWD=$p
                        echo "Password Verification SUCCESS"
                        break
                fi
         done
                if [ -z "$PSWD" ];then
                        echo "Login" "Permission DENIED @ $USR@$IPADR" #>> /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.log
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

		if [ $ZONE = 'EMS' ]; then
			FILTER="awk -v HN=$HOST_NAME -v IP=$IPADR -v APP_ID=$DPID -v Z=$ZONE 'BEGIN{OFS=\",\";U=\"0\";} {tot[substr(\$4,2,16)]++;if(length(\$1) > 15) ipv6[substr(\$4,2,16)]++; else ipv4[substr(\$4,2,16)]++; if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) success[substr(\$4,2,16)]++; else failure[substr(\$4,2,16)]++; if(\$10 ~ /^[0-9][0-9][0-9]$/) data[substr(\$4,2,16)]+=\$11; else data[substr(\$4,2,16)]+=\$12; if(\$(NF-5) ~ /[0-9].[0-9]/) {time[substr(\$4,2,16)]+=\$(NF-5); if (\$(NF-5)>$SEC) buff[substr(\$4,2,16)]++} else {time[substr(\$4,2,16)]+=\$(NF-6);if (\$(NF-6)>$SEC) buff[substr(\$4,2,16)]++;}; if (\$6==\"HIT\") hit[substr(\$4,2,16)]++; else miss[substr(\$4,2,16)]++;} END {for (var in tot) print \"STR_TO_DATE( \x27\" substr(var,1,11) \"\x27\", \"\x27\" \"%d/%b/%Y\" \"\x27 )\",  \"\42\" substr(var,13,16)U \"\42\", APP_ID, \"\42\" Z \"\42\", \"\42\" HN \"\42\", \"\42\" IP \"\42\", buff[var]+1,  tot[var]+2, buff[var]*100/(tot[var]+.001),  hit[var]+1, miss[var]+1, hit[var]*100/(tot[var]+.0001), success[var]+1, failure[var]+1, success[var]*100/(tot[var]+.001), time[var]/(tot[var]+.0001), data[var] ,  ipv6[var]+1, ipv4[var]+1, ipv6[var]*100/(tot[var]+.0001), \"VISHAL\";}'"
		else
			FILTER="awk -v HN=$HOST_NAME -v IP=$IPADR -v APP_ID=$DPID -v Z=$ZONE 'BEGIN{OFS=\",\";} {tot[substr(\$4,2,16)]++;if(length(\$1) > 15) ipv6[substr(\$4,2,16)]++; else ipv4[substr(\$4,2,16)]++; if (\$10 ~ /^2[0-9][0-9]$/ || \$11 ~ /^2[0-9][0-9]$/) success[substr(\$4,2,16)]++; else failure[substr(\$4,2,16)]++; if(\$10 ~ /^[0-9][0-9][0-9]$/) data[substr(\$4,2,16)]+=\$11; else data[substr(\$4,2,16)]+=\$12; if(\$(NF-4) ~ /[0-9].[0-9]/) {time[substr(\$4,2,16)]+=\$(NF-4); if (\$(NF-4)>$SEC) buff[substr(\$4,2,16)]++} else {time[substr(\$4,2,16)]+=\$(NF-5);if (\$(NF-5)>$SEC) buff[substr(\$4,2,16)]++;}; if (\$6==\"HIT\") hit[substr(\$4,2,16)]++; else miss[substr(\$4,2,16)]++;} END {for (var in tot) print \"STR_TO_DATE( \x27\" substr(var,1,11) \"\x27\", \"\x27\" \"%d/%b/%Y\" \"\x27 )\",  \"\42\" substr(var,13,16) \"\42\", APP_ID, \"\42\" Z \"\42\", \"\42\" HN \"\42\", \"\42\" IP \"\42\", buff[var]+1,  tot[var]+2, buff[var]*100/(tot[var]+.001),  hit[var]+1, miss[var]+1, hit[var]*100/(tot[var]+.0001), success[var]+1, failure[var]+1, success[var]*100/(tot[var]+.001), time[var]/(tot[var]+.0001), data[var] ,  ipv6[var]+1, ipv4[var]+1, ipv6[var]*100/(tot[var]+.0001), \"VISHAL\";}'"
		fi
#if [ $DAY = 'Y' ]; then
#DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "zcat /var/log/nginx/access_$DPID\.log-$DATE.gz /var/log/nginx/access_$DPID\.log-$DATE1 | grep -v ' 503 '| $FILTER") #>>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
#		DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE1 /var/log/nginx/access_$DPID\.log | grep -v ' 503 '| $FILTER") #>>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
#else
#		DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE /var/log/nginx/access_$DPID\.log | grep -v ' 503 '| $FILTER") #>>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
		DATA1=$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE | $FILTER") #>>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
#fi
#$(sshpass -p $PASS $SSH $USR@$IPADR "cat /var/log/nginx/access_$DPID\.log-$DATE /var/log/nginx/access_$DPID\.log | grep -v ' 503 '| $FILTER") >>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
		if [ $? -eq 0 ]; then
			echo $DATA1 >>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
		#else
		#	echo $DATA1 >>/home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.log
		fi
#echo /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
#DATA7=$(sshpass -p $PASS $SSH $USR@$IPADR "cat $LOGFILE-$DATE |$BUFFER")
#echo $DATA1 #>> /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
#echo $IP"|"$DATA4"|"$DATA7 >> $DPIDNAME-$DATE
#echo "-----------------------Done-----------------------------------"
	done
checkDbConnection() {
	MysqlConnectionStatus=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER --password=$DB_USER_PASSWORD -e "show databases;"|grep -m 1 "$DB_DBNAME")
	if [[ $MysqlConnectionStatus != "$DB_DBNAME" ]]
	then
        	echo
        	echo "The DB connection could not be established. Check the database details and try again."
        	echo 'The DB connection could not be established. Check the database details and try again.' |mailx -s "Report is not updated in DB" -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
#sendEmail "Unable to connect database server \"$DB_HOST\""
       # echo
        	exit 1
	fi
}
sed -i "s/,VISHAL/);\\n/g" /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE #> /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.csv
sed -i "/^\s*$/d" /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
sed -i "s/
//g" /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE
sed -e "s/^/INSERT IGNORE INTO SASO_CDN_HOURLY_STATS(DATE,HOUR_MIN,APP_ID,ZONE,HOSTNAME,IP,BUFFERING_REQUESTS,TOTAL_REQUESTS,BUFFERING_PERCENTAGE,TOTAL_HITS,TOTAL_MISS,HIT_PERCENTAGE,TOATAL_SUCCESS,TOTAL_FAILURES,SUCCESS_PERCENTAGE,AVG_RESPONSE_TIME,DATA_CONSUMPTION_IN_GB,IPV6_COUNT,IPV4_COUNT,IPV6_PERCENTAGE) VALUES(/g" /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE > /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql
#sed -i "/.*No such file or directory$/d" /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql
#sed -i "/.*cdns/d" /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql
#rm /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE 
#less /home/jioadm/reports/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE 
checkDbConnection
mysql -h $DB_HOST -u $DB_USER -p$DB_USER_PASSWORD -P $DB_PORT $DB_DBNAME < /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql 
#echo "mysql -h $DB_HOST -u $DB_USER -p$DB_USER_PASSWORD -P $DB_PORT $DB_DBNAME < /tmp/CDN_HOURLY_STATS_$ZONE-$SITENAME-$DPID-$DATE.sql"
#echo 'PFA report' |mailx -s "CDN Daily Response Time Report from $ZONE for $DATE" -a /home/jioadm/reports/CDN_STATS_$ZONE-$SITENAME-$DPID-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com,deepak12.gupta@ril.com,pratiksha.thuturkar@ril.com
