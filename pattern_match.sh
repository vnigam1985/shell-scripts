#!/bin/sh
array1=`cat $1`
array2=`cat $2`


for i in @array1
do
for j in @array2
grep $i $j >> output.lst
done

done
