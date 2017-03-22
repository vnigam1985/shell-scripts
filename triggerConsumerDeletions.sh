#!/bin/sh
#
#
# Purpose: Deletions from CDB database per market
#
# Modified: 2013-06-20 - change in xml format of WslCookie - WSL-internal is now a tag instead of value
#
CDB_APP_ROOT="/proj/cdb/was/install"
CDB_LOG_DIR="/proj/cdb/was/logs"
CURL_PROGRAM=$(whereis curl | cut -f2 -d' ')

URL="http://ecrm.volvocars.net:61080/dma/triggerConsumerDeletions.do?task=doTriggerConsumerDeletions&marketCode=AU&marketCode=AT&marketCode=BE&marketCode=BR&marketCode=CH&marketCode=CN&marketCode=DE&marketCode=FR&marketCode=IT&marketCode=JP&marketCode=RU&marketCode=PT&marketCode=MX&marketCode=TW&marketCode=GB&marketCode=ZA&marketCode=IN&marketCode=IE"

WSL_PROPS_FILE=$(ls ${CDB_APP_ROOT}/*/properties/WslCookies.xml)
if [[ -f "${WSL_PROPS_FILE}" ]]; then
	WSL_COOKIE=$(cat ${WSL_PROPS_FILE} | grep -v "#" | grep "WSL-internal" | cut -f2 -d">" | cut -f1 -d"<" | uniq)
else
	echo "Unable to set WSL cookie. Execution of script aborted!"
	exit
fi

if [[ ${WSL_COOKIE} != "" ]]; then
	echo "WSL cookie set and now running the deletion script"
	#echo "WSL-internal=${WSL_COOKIE}"
	${CURL_PROGRAM} -b "WSL-internal=${WSL_COOKIE}" "${URL}" -o ${CDB_LOG_DIR}/triggerConsumerDeletions_$(date '+%Y%m%d_%H%M').log
else
	echo "WSL cookie not set. Perhaps format of the WslCookies.xml file has changed"
fi
