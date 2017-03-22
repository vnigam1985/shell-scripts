LOG_FILE=Populate_CDB_Diag_tables.log

if [ -z "$1" ]; then
        echo -e "You must provide a connect-string as parameter to the script!"
        exit 1
fi

sqlplus -s $1 @/home/bpp00cdb/tool_box/sql/Populate_CDB_Diag_tables.sql

exit
/
