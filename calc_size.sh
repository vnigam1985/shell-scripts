#!/bin/bash
# Tool to measure root (/) disk space used and available on the network
# Initialize the variables
TOTAL=0
USED=0
OUT=""
# Create an array of the machines to be accessed
MACHINES=( 192.168.0.103 192.168.0.101 )
# Loop through the array, SSH to each machine and run df /. We want to ommit the header line of the output so we use tail -n +2 for this. We use the ~ character as
# a delimiter to be able to easily parse the output using cut command
for m in "${MACHINES[@]}"
	do
		OUT="$OUT~`ssh  $m 'df / | tail -n +2'`"
	done
# Calculate the number of machines in the array. We add 1 to the number because the delimiter makes cut regard the field 2 as the first machine output
LENGTH=${#MACHINES[@]} 
LENGTH=$((LENGTH + 1))
# Loop through the output of df with the help of teh delimiter (~). Start at 2, which refers to the output of the first machine. Then parse this output to get
# the total and the available sizes (in KB). 
for (( i=2; i<=$LENGTH; i++ ))
	do
		USED_TEMP=`echo $OUT | cut -d "~" -f $i | cut -d " " -f 3`
		TOTAL_TEMP=`echo $OUT | cut -d "~" -f $i | cut -d " " -f 2`
		USED=$((USED+USED_TEMP))
		TOTAL=$((TOTAL+TOTAL_TEMP))
	done
# Convert the total to GB for easier reading
TOTAL=$((TOTAL/1024/1024))
USED=$((USED / 1024 / 1024))
echo "Total is " $TOTAL " GB"
echo "Total used is " $USED " GB"

