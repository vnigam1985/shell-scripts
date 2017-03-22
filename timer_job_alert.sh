# SCRIPT NAME   : Timer_Job_Alert.sh
# PURPOSE       : To send Alerts, if Timer job stop working on any of the market
# CREATE DATE   : September 20, 2013
# CREATOR       : Mayuresh Khismatrao, capgemini, India
# RESTART       : Can be restarted without any data manipulation
# INPUT PARMS   : Not required
#
#==================================================================================
#                          MODIFICATION LOG
# CSR#   |DATE      |WHO| COMMENTS
#        |(yyyymmdd)|   |
#==================================================================================
#        |          |   |
#----------------------------------------------------------------------------------
#        |          |   |
#----------------------------------------------------------------------------------
#        |          |   |
###################################################################################

#------------------------------------------------------------------------------
# Set variables for accepted parameters, directories, files, etc
#------------------------------------------------------------------------------
InitDir=`pwd`
LogDir='/home/bppautst/tool_box/dpcdbq.cdb_lu_au/log' export LogDir
LogFile='timer_job_alert.log' export LogFile
Time="date +'%x  %T'"
user_id='cdbmon' export user_id
pswd='cdbmon_20130628' export pswd
rm -f $LogDir/$LogFile


#------------------------------------------------------------------------------
#Logon to sqlplus and execute stored proc
#------------------------------------------------------------------------------

sqlplus -s ${user_id}/${pswd} 1>> ${LogDir}/${LogFile} <<EOF

set serveroutput on size 500000
set linesize 100
set head off
set echo off
whenever sqlerror exit failure
   declare
   STR varchar2(1000) := null;
   EPX_ID number;
   CNT number;
   DIF number;
   MC varchar(3);
   t_date  timestamp;
   msg varchar2(4);

   begin

   for i in (select MARKET_CODE  from ssa.market_805 where market_code not in ('IN','NL')) LOOP

   STR := '
     SELECT ''TJOB'',export_id,'||''''||i.market_code||''''||','||'
          (select COUNT (CUST_ID)
             FROM cdb_lu_'||i.market_code||'.export_info_consumer_522
            where CUST_ID not in (select CUST_ID
                                    from cdb_lu_'||i.market_code||'.CLEANSING_ERROR_313)
              and EXPORT_ID = 0) as COUNT,
              case
              when extract(hour from (sysdate - TSTAMP)) > 0 then 100
              when extract(hour from (sysdate - TSTAMP)) = 0 then extract(minute from (sysdate - TSTAMP))
              end as DIFF, TSTAMP
     from CDB_LU_'||i.market_code||'.'||'EXPORT_ID_CONSUMER_523';


     begin
     execute immediate STR into msg,EPX_ID,MC,CNT,DIF,t_date;
     dbms_output.put_line(msg||'|'||epx_id ||'|'||mc||'|'||cnt||'|'||dif||'|'||t_date);
     EXCEPTION
     when OTHERS then
     null;
     end;
     end loop;

   End;
/
EOF
Retn=$?
#------------------------------------------------------------------------------
# Check for errors
#------------------------------------------------------------------------------

if [ $Retn -ne 0 ]
then
  echo " - Sscript Timer_Job_Alert *** FAILED ***, check log file." | tee -a $LogDir/$LogFile
  exit $Retn
else
  echo " - *** COMPLETED SUCCESSFULLY ***." | tee -a $LogDir/$LogFile
fi

sed '/^$/d' < $LogDir/$LogFile > $LogDir/temp_log.log

if [ $? = 0 ]
then
        echo "Temp log successfully created" >> $LogDir/$LogFile
        cat $LogDir/temp_log.log | grep -i "TJOB" > $LogDir/timer_data.dat
                if [ $? = 0 ]
                then
                        echo "Final time data file created" >> $LogDir/$LogFile
                        rm -f $LogDir/temp_log.log
                else
                        echo "Final time data file creation failed" >> $LogDir/$LogFile
                        exit 1
                fi

else
        echo "Temp log creation failed" >> $LogDir/$LogFile
        exit 1
fi

while read line
do

exp_id=`echo $line | cut -d"|" -f2`
mkt=`echo $line | cut -d"|" -f3`
cnt=`echo $line | cut -d"|" -f4`
diff=`echo $line | cut -d"|" -f5`
tstmp=`echo $line | cut -d"|" -f6`

#------------------------------------------------------------------------------
# Send mail to CRM Support Team informing Integration Issue
#------------------------------------------------------------------------------

if [ $cnt != 0  ]
then
        if [ $diff -gt 30 ]
        then
                echo "Mkt   Export_Id   Count " > timer_job.msg
                echo "${mkt}    ${exp_id}       ${cnt}"  >> timer_job.msg
                echo "Timer Last Run at :-  ${tstmp}" >> timer_job.msg
                mailx -s "Alert - Timer has been stopped for ${mkt} market"  mskhisma@volvocars.com < timer_job.msg
                rm  timer_job.msg
        fi

fi
done < $LogDir/timer_data.dat

#------------------------------------------------------------------------------
# EOS - End of script
#-------------------------------------------------------------------------------
