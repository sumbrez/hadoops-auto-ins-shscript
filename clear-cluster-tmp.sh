#!/bin/bash

echo "=== running $(basename $0) ==="

source config

while read line
do
	ip=`echo $line | awk '{print $1}'`
	hostname=`echo $line | awk '{print $2}'`

	if [ $hostname = `hostname` ]; then # 本机
		rm -r $tmpdir/h*
	else # slave
		ssh -t -t $uname@$hostname "rm -r $tmpdir/h*"
	fi
done < hosts
