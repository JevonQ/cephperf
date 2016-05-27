#!/bin/sh
#
# This script could be used to evaluate the performance of a single disk
#

source ./library/gatherinfo.sh
source ./library/fio/disk-test.sh

function eval_disk_1job64dep()
{
    local disk_list=$1
    local hostname=`gethostname`
    local date=`date --rfc-3339=seconds | sed "s/ /_/g"`
    for diskid in ${disk_list}
    do
	logname=${hostname}-${diskid}-1job64dep-${date}
	# 4k randwrite
	fio_randtest /dev/${diskid} 4k libaio randwrite $logname 1
	echo "Finished 4k randwrite perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 4k randread
	fio_randtest /dev/${diskid} 4k libaio randread $logname 1
	echo "Finished 4k randread perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 64k write
	fio_seqtest /dev/${diskid} 64k libaio write $logname 1
	echo "Finished 64k write perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 64k read
	fio_seqtest /dev/${diskid} 64k libaio read $logname 1
	echo "Finished 64k read perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10
    done
}
#export -f eval_disk_1job64dep

function eval_disk_64job1dep()
{
    local disk_list=$1
    local hostname=`gethostname`
    local date=`date --rfc-3339=seconds | sed "s/ /_/g"`
    for diskid in ${disk_list}
    do
	logname=${hostname}-${diskid}-64job1dep-${date}
	# 4k randwrite
	fio_randtest /dev/${diskid} 4k libaio randwrite $logname 64
	echo "Finished 4k randwrite perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 4k randread
	fio_randtest /dev/${diskid} 4k libaio randread $logname 64
	echo "Finished 4k randread perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 64k write
	fio_seqtest /dev/${diskid} 64k libaio write $logname 64
	echo "Finished 64k write perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10

	# 64k read
	fio_seqtest /dev/${diskid} 64k libaio read $logname 64
	echo "Finished 64k read perf test against $diskid"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10
    done
}
#export -f eval_disk_64job1dep

eval_disk_1job64dep sda
eval_disk_64job1dep sda
