#!/bin/sh
#
# Purpose: check status of message listeners for a given application/project
#
DEPLOY_ROOT="/proj/deploy/"
LISTENER_CHK_SCRIPT="$(dirname $0)/message_listener_check.py"
WASDM_PROFILE_ROOT="/usr/local/WebSphere/AppServer/profiles/dmgr"
#RECIPIENTS="wasopvcc@volvocars.com crmsupp@volvocars.com"
RECIPIENTS="crmsupp@volvocars.com"
SUBJECT="ALERT: MESSAGE LISTENERS NOT RUNNING FOR"
PROJECT=""

declare -a appnode_data

function send_mail() {
	LISTENER_ERR_FILE="${DEPLOY_ROOT}/${PROJECT}/${1}_error_listeners.txt"
	APPSERVER=$(echo ${1} | tr '[:lower:]' '[:upper:]')
	NODE=$(echo ${2} | tr '[:lower:]' '[:upper:]')

	if [ -s ${LISTENER_ERR_FILE} ]; then
		#${MAILPROG} -s "${SUBJECT} ${APPSERVER} ON ${NODE}" ${RECIPIENTS} < $LISTENER_ERR_FILE
		mail -s "${SUBJECT} ${APPSERVER} ON ${NODE}" ${RECIPIENTS} < $LISTENER_ERR_FILE
		rm ${LISTENER_ERR_FILE}
	fi
}

if [ $# -lt 1 ]; then
	echo "USAGE:  $0 <<application/name of directory in /proj/deploy on DM"
	exit
else
	PROJECT=${1}

	apps_nodes=$(cat ${DEPLOY_ROOT}/${PROJECT}/main.jacl | grep clusterM | grep -v grep | cut -f3,4 -d'{' | cut -f2,4 -d' ' | tr '}' ' ')
	appnode_data=(${apps_nodes/,/ /})	

	echo ${appnode_data[@]}
	cnt=0
	for((;${cnt} < ${#appnode_data};cnt=$((${cnt} +2))));do 	
		appserver=$(echo ${appnode_data[$cnt]} | sed -e's/ //')
		node=$(echo ${appnode_data[$cnt+1]} | sed -e's/ //')
		echo "App:$appserver"; 
		echo "Node:$node"; 
		if [ -e ${LISTENER_CHK_SCRIPT} ]; then 
			if [[ -n "${node}" ]] && [[ -n "${appserver}" ]]; then
				${WASDM_PROFILE_ROOT}/bin/wsadmin.sh -lang jython -f ${LISTENER_CHK_SCRIPT} ${appserver} ${node}; 
				send_mail ${appserver} ${node} ${PROJECT}
			fi
		else 
			echo "Error: ${LISTENER_CHK_SCRIPT} does not exist!!!"
		fi
	done
fi
