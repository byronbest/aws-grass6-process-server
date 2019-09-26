#!/bin/bash

if [ -e /media/ephemeral0/grassdata ] ; then
GRASSDBASE=/media/ephemeral0/grassdata
rsync -aq /study/grassdata/ $GRASSDBASE
else
GRASSDBASE=/study/grassdata
fi
export GRASSDBASE
export ALARMTIME=600
export TIMEOUT="sync TIMEOUT cannot start"

for i in rc service-request.py startrc ; do
	timeout $ALARMTIME aws s3 cp s3://ltpt-grass-process/$i $i
done
for i in bin unit_parameters unit_process ; do
	timeout $ALARMTIME aws s3 sync s3://ltpt-grass-process/$i $i
done
chmod +x bin/* *py *sh unit_process/*

. startrc

if [ "`aws s3 ls s3://grassdata/sync-done`" == "" ] ; then
trys=0
until timeout $ALARMTIME aws s3 sync s3://grassdata $GRASSDBASE ; do

let trys=$trys+1
aws sns publish --topic "$STATUSNOTE" --message "$TIMEOUT"
if [ $trys -gt 10 ]; then
	exit
fi

done
fi

q=(`cat queue_name`)
n=0
if [ "x${q[n]}" == "x" ] ; then
aws sns publish --topic "$STATUSNOTE" --message "missing queue_name"
exit
fi

for ((i=1; $i<=$START_SERVERS; i++)) {
	JOBHOME=RUN$i
	if [ "x${q[n]}" == "x" ] ; then n=0 ; fi
	./service-request.py ${q[n]} $JOBHOME &
	let n=n+1
	sleep 1
}

exit 0

