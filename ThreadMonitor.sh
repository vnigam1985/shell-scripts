#!/bin/bash
#
# Creator:Vishal Nigam
#
# This script monitors the threads in the WAS node, and if it goes above the defined limit, it sends an alert to WASOps and CRM Support.

#Variables
NODE=$(hostname)
TO="crmsupp@volvocars.com,ITAMON@volvocars.com"
FROM="crmsupp@volvocars.com"
SUBJECT="Urgent::Hanging Threads in ${NODE}"
#Change the log file path accordingly
LOGPATH="/home/vnigam/SystemOut.log"
ThreadCount=$(cat ${LOGPATH} | grep ThreadMonitor | tail -1 | grep -Eo '[0-9]{1,4}' | tail -1)

if [ ${ThreadCount} -gt 35 ]
then
mail -s "${SUBJECT}" -r "${FROM}" ${TO} <<END;
Hello Monitoring Team,

Please create a P2 incident towards WAS Ops for restarting the CDB node ${NODE} , As hanging thread count is increased to ${ThreadCount}.
Please let us know once restart is done.

Thanks and Regards,
CRM Support


END
fi
exit

<<COMMENT1
#Change the log file path accordingly
SERVERS=("gotsvl1149:$1" "gotsvl1150:$2" "gotsvl1151:$3")

for serverdict in "${SERVERS[@]}"; do
        server=${serverdict%%:*}
        appserver=${serverdict#*:}
        APPSERVER_WORKDIR="/data01/${server}/customers/${appserver}"
        LOGDIR="${APPSERVER_WORKDIR}/serverlogs"
        LOGPATH="${LOGDIR}/SystemOut.log"

        ThreadCount=$(cat ${LOGPATH} | grep ThreadMonitor | tail -1 | grep -Eo '[0-9]{1,4}' | tail -1)

        if [[ ${ThreadCount} -gt 35 ]]
        then
                echo -e "Hello Monitoring Team,\n\n Please create a P2 incident towards WAS Ops for restarting the CDB node ${server}, \
   As hanging thread count is increased to ${ThreadCount}. Please let us know once restart is done. \
                \n\nThanks,\nCRM Support" \
                | mail -s "${SUBJECT}${server}" -r "${FROM}" ${TO}
        fi
done
exit
COMMENT1


