#!/bin/bash
#
# Creator:Vishal Nigam
#
# This script restarts Uniserv and sends the alert if Uniserv license usage reaches to its maximum limit.
# A mail is send to crmsupp@volvocars.com

#Variables
TO="crmsupp@volvocars.com"
FROM="crmsupp@volvocars.com"
SUBJECT="Uniserv restarted"
restart="/data01/bppunisr/uniserv/restart.sh >> /dev/null"
date=`date`
for line in `/data01/bppunisr/uniserv/lsrvadm gotsvl1088 | tr -s ' ' '#'`
do
 array+=("$line")
done

for ((i=0; i < ${#array[*]}; i++))
do
#echo ${array[$i]}
market_name=`echo ${array[$i]} | cut -d'#' -f3`
nol=`echo ${array[$i]} | cut -d'#' -f4`
liu=`echo ${array[$i]} | cut -d'#' -f6`

if [ $liu -gt 42 ]
then
echo ${market_name}${liu}" "${date} >> /data01/bppunisr/uniserv/above42.lst
fi

if [ $liu -eq $nol ] || [ $liu -gt $nol ]
then
echo "${market_name}${liu}`date`" >> /data01/bppunisr/uniserv/market.lst
echo "restarting the uniserv as license reached to max limit for $market_name at time `date`"
`/data01/bppunisr/uniserv/restart.sh >> /dev/null`
sleep 30
if [ $? -eq 0 ]
then
mail -s "${SUBJECT}" -r "${FROM}" ${TO} <<END;
Hello,
No of licenses in use for $market_name is reached to no of licenses available. Hence we have restarted the Uniserv.
Kindly check if it's working fine.

Thanks and Regards,
CRM Support

END
exit
fi
fi
done
