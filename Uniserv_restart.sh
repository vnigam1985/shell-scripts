#!/bin/bash
#
# Creator:Vishal Nigam
#
# This script sends alert if Uniserv lisence expires.
# A mail is send to crmsupp@volvocars.com


#Variables
log_name=/home/vnigam/gca.log
curr_date=$(date +"%Y-%m-%d %H:%M")
search_string1=".*ERROR com.ford.mss.cdb.gca.persistence.cdb.JdbcNormalisationDao - 'An SQL error occurred when normalising'"
NODE=$(hostname)
restart="/home/vnigam/restart_unisr.sh >>/dev/null"
TO="vnigam@volvocars.com,msharm22@volvocars.com,mgunjal@volvocars.com,pashutos@volvocars.com"
FROM="crmsupp@volvocars.com"

# Variables for the mail-script


SUBJECT="Restart Uniserv"

cat $log_name | grep "$curr_date$search_string1" > /dev/null

if [ $? -eq 0 ]
then
`$restart`
mail -s "${SUBJECT}" -r "${FROM}" ${TO} <<END;
Hello,
We have got 'An SQL error occurred when normalising' on node ${NODE} and Unable to obtain license from Uniserv. Hence we have restarted the Uniserv.
Kindly check if it's working fine.

Thanks and Regards,
CRM Support

END
fi
