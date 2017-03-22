#!/bin/bash
sqlplus -s ${CDB_LU_USER}/${CDB_LU_PASSWD} @/home/$(whoami)/tool_box/sql/CreateReport.sql
mail -s "UK Error Report" -a "/home/$(whoami)/Error_report.csv"  peter.brylde@volvocars.com < /home/$(whoami)/file5.log
rm /home/$(whoami)/Error_report.csv
rm /home/$(whoami)/file5.log
#EXIT