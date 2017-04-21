#!/bin/bash
#Initialize the sum variable to zero
SUM=0
# Execute the find command and store the output to a variabe FILES
FILES=`find / -mount -type f -mtime -1 | xargs du -k | awk '{print $1}'`
# Loop through this variables line by line and add the file size to the sum variable
for i in $FILES; do
	SUM=$((SUM+i))
done
# The sizes were calculated in KB. Let's convert it to MB
SUM=$((SUM/1024))
# Send an e-mail to root with this information
echo "$SUM MB" | mail -s "$HOSTNAME Frequently Changed files" root
