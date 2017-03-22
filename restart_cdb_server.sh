#!/bin/ksh
#########################################################################
# Copyright Capgemini Consulting India (2012)                   	#
#########################################################################
#  Date:	26-June-2012						#
#  Program:     restart_cdb_server.sh                           	#
#  Programmer:  Vishal Nigam                                    	#
#  Language:    UNIX ksh Script                                 	#              
#  Purpose:     If SOAPFaultException occurs,sends an email alert 	#
#		to crmsupp and WAS ops   				#
#                                                			#
#  Input:      Node name                                                #      
#  Output:     Email to CRM Support and WAS ops 	                #                                                            #
#########################################################################
# Path to the wanted files
# Variables for the mail-script
#SUBJECT="Restart of CDB Application on node $1"

TO="mikio.holum@volvocars.com,crmsupp@volvocars.com,mvsuma@volvocars.com,nvista@volvocars.com,itamon@volvocars.com,johan.manning@volvocars.com,tommy.linnarskar@volvocars.com"
FROM="crmsupp@volvocars.com"
#v_Message="Hello, \nWe are recieving SOAPFaultException on node $1, please restart the node $1 and clear the transaction logs before restarting. Please send us an update when its done. \n\nThanks an d Regards, \nCRM Support"
#echo $v_Message | mail -s "${SUBJECT}" -r "${FROM}" ${TO}

#
# Changes to script - WASOPVCC 26/06/2012
#
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <<appserver>>"
	exit 3
fi

# Variables for the mail-script
APPSERVER=${1}
NODE=$(hostname)
SUBJECT="Restart of CDB Application on node ${NODE}"

mail -s "${SUBJECT}" -r "${FROM}" ${TO} <<END;
Hello,
	SOAPFaultException errors have been detected on node ${NODE} which require an application server restart to fix.
	Please perform the following actions:
	
	1. On server ${NODE}, Stop the application server ${APPSERVER}
	2. Clear the transaction logs for ${APPSERVER} in the 
	   \${WAS_PROFILE_HOME}/tranlogs/\${CELLNAME}/${NODE}/${APPSERVER}/transaction directory
	3. Start the application server ${APPSERVER}
	4. Send an email to crmsupp@volvocars.com when the restart has been completed.

	Thanks and Regards,
	CRM Support
END
