#!/bin/bash

SSH="ssh -t -q -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
ZONE=$1
SITENAME=$2
if [ $# -lt 2 ]; then
echo "Format:  sh SystemStats_SQL.sh DS/EMS XXX"
echo "XXX above is SiteCode like mum/bhpl/amdb/ptna/ngpr/chnn/koch/jpur/hdbd/agra/lckn/klkt/ldhn/dlhi/bglr or all in case of all site stats"
exit
fi
if [ $SITENAME = 'all' ]; then
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT`
else
IP_LIST=`cat /home/jioadm/files/CDN_IP_LIST_$ZONE.TXT |grep $SITENAME`
fi
DATE=$(date +%Y%m%d)
YDAY=$(date +%Y%m%d -d "Yesterday")
TIME=$(date -d '1 hour ago' +%H:00:00)
DB_HOST="10.137.2.4"
DB_USER="sasorw"
DB_USER_PASSWORD="sasorw@246"
DB_PORT="3306"
DB_DBNAME="sasodb"
USR='jioadm'
echo "HOSTNAME,IP,Date,Time,CPU_USR_avg,CPU_USR_max,CPU_Iowait_avg,CPU_Iowait_max,CPU_SYSTEM_avg,CPU_SYSTEM_max,CPU_IDLE_avg,CPU_IDLE_min,LOAD_avg_avg,LOAD_avg_max,RAM_avg,RAM_max,BOND1_Network_avg_IN,BOND1_Network_max_IN,BOND1_Network_avg_OUT,BOND1_Network_max_OUT,BOND0_Network_avg_IN,BOND0_Network_max_IN,BOND0_Network_avg_OUT,BOND0_Network_max_OUT" >> /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE.csv
function PSWD_LIST()
        {

                                echo "Password" "Verification" " PROGRESS "
				PSW_LIST=`cd /opt/CARKaim/sdk/;./clipasswordsdk GetPassword -p AppDescs.AppID=AIMcdn -p Query="username=jioadm;Folder=Root;Address=$IPADR" -p RequiredProps=UserName -o Password`
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

CPU_USR_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME| /bin/grep Average: | /bin/awk {'print \$3'}")
CPU_USR_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME| /bin/grep -v -E '(Average|user|Linux|/)'| /bin/awk {'print \$4'} | /bin/sort -n| /usr/bin/tail -1")
CPU_Iowait_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME| /bin/grep Average: | /bin/awk {'print \$6'}")
CPU_Iowait_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME|/bin/grep -v -E '(Average|user|Linux|/)'| /bin/awk {'print \$7'} | /bin/sort -n| /usr/bin/tail -1")
CPU_SYSTEM_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME| /bin/grep Average: | /bin/awk {'print \$5'}")
CPU_SYSTEM_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME|/bin/grep -v -E '(Average|user|Linux|/)'| /bin/awk {'print \$6'} | /bin/sort -n| /usr/bin/tail -1")
CPU_IDLE_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME| /bin/grep Average: | /bin/awk {'print \$8'}")
CPU_IDLE_min=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -u -s $TIME|/bin/grep -v -E '(Average|user|Linux|/)'| /bin/awk {'print \$9'} |/bin/sort -n | /usr/bin/head -2 | /usr/bin/tail -1")
LOAD_avg_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -q -s $TIME| /bin/grep Average: | /bin/awk {'print \$6'}")
LOAD_avg_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -q -s $TIME| /bin/grep -v -E '(Average|user|Linux|/)'| /bin/awk {'print \$7'} | /bin/sort -n| /usr/bin/tail -1")
#RAM_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -r -s $TIME| /bin/grep Average: | /bin/awk {'print \$4'}")
#RAM_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -r -s $TIME| /bin/grep -v -E '(Average|kbmemused|Linux|/)'| /bin/awk {'print \$5'} | /bin/sort -n| /usr/bin/tail -1")
RAM_avg=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -r -s $TIME| /bin/grep Average: | /bin/awk {'print \$2/1024/1024'}")
RAM_max=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -r -s $TIME| /bin/grep -v -E '(Average|kbmemused|Linux|/)'| /bin/awk {'print \$3/1024/1024'} |/bin/sort -n| /usr/bin/tail -1")
BOND1_Network_avg_IN=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond1| /bin/grep Average | /bin/awk {'print \$5'}")
BOND1_Network_max_IN=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond1| /bin/grep -v Average| /bin/awk {'print \$6'} | /bin/sort -n| /usr/bin/tail -1")
BOND1_Network_avg_OUT=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond1|/bin/grep Average | /bin/awk {'print \$6'}")
BOND1_Network_max_OUT=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond1| /bin/grep -v Average| /bin/awk {'print \$7'} | /bin/sort -n| /usr/bin/tail -1")
BOND0_Network_avg_IN=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond0| /bin/grep Average | /bin/awk {'print \$5'}")
BOND0_Network_max_IN=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond0| /bin/grep -v Average| /bin/awk {'print \$6'} | /bin/sort -n| /usr/bin/tail -1")
BOND0_Network_avg_OUT=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond0|/bin/grep Average | /bin/awk {'print \$6'}")
BOND0_Network_max_OUT=$(sshpass -p $PASS $SSH $USR@$IPADR "/usr/bin/sar -n DEV -s $TIME| /bin/grep bond0| /bin/grep -v Average| /bin/awk {'print \$7'} | /bin/sort -n| /usr/bin/tail -1")

echo "'"$HOST_NAME"','"$IPADR"','"$DATE"','"$TIME"','"$CPU_USR_avg"','"$CPU_USR_max"','"$CPU_Iowait_avg"','"$CPU_Iowait_max"','"$CPU_SYSTEM_avg"','"$CPU_SYSTEM_max"','"$CPU_IDLE_avg"','"$CPU_IDLE_min"','"$LOAD_avg_avg"','"$LOAD_avg_max"','"$RAM_avg"','"$RAM_max"','"$BOND1_Network_avg_IN"','"$BOND1_Network_max_IN"','"$BOND1_Network_avg_OUT"','"$BOND1_Network_max_OUT"','"$BOND0_Network_avg_IN"','"$BOND0_Network_max_IN"','"$BOND0_Network_avg_OUT"','"$BOND0_Network_max_OUT"');" >> /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME
#echo 'PFA report' |mailx -s "Today's buffering Report" -a /home/jioadm/UserCDN-$DATE.csv  -r vishal.nigam@ril.com Jio.TopsSASOCDNOps@ril.com
done
sed -i "s///g" /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME
sed -i "/'','');$/d" /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME
cat /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME >> /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE.csv
#echo 'PFA report' |mailx -s "System Stats summary after $DATE $TIME for $ZONE" -a /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE.csv -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
echo 'PFA report' |mailx -s "System Stats summary from $DATE for $ZONE" -a /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE.csv  -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
checkDbConnection() {
        MysqlConnectionStatus=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER --password=$DB_USER_PASSWORD -e "show databases;"|grep -m 1 "$DB_DBNAME")
        if [[ $MysqlConnectionStatus != "$DB_DBNAME" ]]
        then
                echo
#               echo "The DB connection could not be established. Check the database details and try again."
                echo 'The DB connection could not be established. Check the database details and try again.' |mailx -s "Report is not updated in DB" -r Jio.TopsSASOCDNOps@ril.com Jio.TopsSASOCDNOps@ril.com
                exit 1
        fi
}
sed -e "s/^/INSERT IGNORE INTO CDN_SYSTEM_STATS(HOSTNAME,IP,Date,Time,CPU_USR_avg,CPU_USR_max,CPU_Iowait_avg,CPU_Iowait_max,CPU_SYSTEM_avg,CPU_SYSTEM_max,CPU_IDLE_avg,CPU_IDLE_min,LOAD_avg_avg,LOAD_avg_max,RAM_avg,RAM_max,BOND1_Network_avg_IN,BOND1_Network_max_IN,BOND1_Network_avg_OUT,BOND1_Network_max_OUT,BOND0_Network_avg_IN,BOND0_Network_max_IN,BOND0_Network_avg_OUT,BOND0_Network_max_OUT) VALUES(/g" /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME > /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME.sql
checkDbConnection
mysql -h $DB_HOST -u $DB_USER -p$DB_USER_PASSWORD -P $DB_PORT $DB_DBNAME < /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME.sql 
rm /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME.sql /home/jioadm/reports/SystemStatCDN-$ZONE-$DATE-$TIME /home/jioadm/reports/SystemStatCDN-$ZONE-$YDAY.csv 
