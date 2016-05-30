#!/bin/sh
#
# This script includes some test functions based on fio
#
source ./library/format.sh

fioruntime=10
fioramptime=10
size=480G

function fio_randtest()
{
    local diskid=$1
    local blocksize=$2
    # Currently, only libaio and rbd are supported
    local ioengine=$3
    local readwrite=$4
    local runname=$5
    local numjobs=$6
    local fiocmd=fio

    # Sanity check for the parameters
    if [[ $ioengine != "libaio" && $ioengine != "rbd" ]]; then
        echo "ERROR: ioengine is not correct, please have a check"
	return 1
    fi

    if [[ $readwrite != "randwrite" && $readwrite != "randread" ]]; then
	echo "ERROR: readwrite keyword is not correct, please have a check"
	return 1
    fi

    if [[ $numjobs < 0 || ($numjobs != 1 && $numjobs != 64) ]]; then
	echo "ERROR: please input 1 or 64 for numjobs"
	return 1
    fi

    # diskid should be a absolute path
    if [[ -z `echo $diskid | grep "\/dev\/" | grep -v grep` ]];then
	echo "ERROR: please provide the correct device path"
	return 1
    fi

    if [[ $blocksize != "4k" && $blocksize != "8k" ]];then
	echo "ERROR: please check the block size, only 4k or 8k are supported"
	return 1
    fi

    # Currently, only 64 jobs and 1 job are supported
    if [[ $numjobs > 1 ]];then
	fiocmd="fio -name=$runname --ioengine=$ioengine -rw=$readwrite -bs=$blocksize -size=$size -direct=1 -thread -runtime=$fioruntime -ramp_time=$fioramptime -time_based -filename=$diskid -sync=1 -norandommap -randrepeat=0 -numjobs=$numjobs -group_reporting -iodepth=1"
    else
	fiocmd="fio -name=$runname --ioengine=$ioengine -rw=$readwrite -bs=$blocksize -size=$size -direct=1 -thread -runtime=$fioruntime -ramp_time=$fioramptime -time_based -filename=$diskid -sync=1 -norandommap -randrepeat=0 -numjobs=$numjobs -iodepth=64"
    fi

    print_pound ${runname}.log
    echo \$$fiocmd >> ${runname}.log
    echo "" >> ${runname}.log
    ${fiocmd} >> ${runname}.log
    print_pound ${runname}.log
}
#export -f fio_randtest

function fio_seqtest()
{
    local diskid=$1
    local blocksize=$2
    # Currently, only libaio and rbd are supported
    local ioengine=$3
    local readwrite=$4
    local runname=$5
    local numjobs=$6
    local fiocmd=fio

    # Sanity check for the parameters
    if [[ $ioengine != "libaio" && $ioengine != "rbd" ]]; then
        echo "ERROR: ioengine is not correct, please have a check"
	return 1
    fi

    if [[ $readwrite != "write" && $readwrite != "read" ]]; then
	echo "ERROR: readwrite keyword is not correct, please have a check"
	return 1
    fi

    if [[ $numjobs < 0 || ($numjobs != 1 && $numjobs != 64) ]]; then
	echo "ERROR: please input 1 or 64 for numjobs"
	return 1
    fi

    # diskid should be a absolute path
    if [[ -z `echo $diskid | grep "\/dev\/" | grep -v grep` ]];then
	echo "ERROR: please provide the correct device path"
	return 1
    fi

    if [[ $blocksize != "64k" && $blocksize != "1m" ]];then
	echo "ERROR: please check the block size, only 64k or 1m are supported"
	return 1
    fi

    # Currently, only 64 jobs and 1 job are supported
    if [[ $numjobs > 1 ]];then
	fiocmd="fio -name=$runname --ioengine=$ioengine -rw=$readwrite -bs=$blocksize -size=$size -direct=1 -thread -runtime=$fioruntime -ramp_time=$fioramptime -time_based -filename=$diskid -sync=1 -numjobs=$numjobs -group_reporting -iodepth=1"
    else
	fiocmd="fio -name=$runname --ioengine=$ioengine -rw=$readwrite -bs=$blocksize -size=$size -direct=1 -thread -runtime=$fioruntime -ramp_time=$fioramptime -time_based -filename=$diskid -sync=1 -numjobs=$numjobs -iodepth=64"
    fi

    print_pound ${runname}.log
    echo $fiocmd >> ${runname}.log
    echo "" >> ${runname}.log
    ${fiocmd} >> ${runname}.log
    print_pound ${runname}.log
}
#export -f fio_seqtest
