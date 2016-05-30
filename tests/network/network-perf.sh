#!/bin/sh
#
# This script could be used to evaluate the performance between two nodes.
# Three parameters are needed here, one is host ip prefix, one is ip range, and
# one is cluster ip prefix
#
ip_prefix=10.0.101
ip_range=68,69,70
ip_cluster_prefix=10.0.117
timeout_val=10
ping_count=10
declare -a nodes

function start_iperfserver()
{
	local server=$1
	timeout $timeout_val ssh -l root $server "iperf -s" > /dev/null 2>&1 &
}

function stop_iperfserver()
{
	local server=$1
	timeout $timeout_val scp kill-iperf.sh root@$server:/tmp/
	timeout $timeout_val ssh root@$server "sh /tmp/kill-iperf.sh"
}

function print_array()
{
    local array=(${nodes[@]})
    i=0
    j=${#nodes[@]}
    while [[ $i -lt $j ]]
    do
	echo ${array[$i]}
	((i++))
    done
}

# After calling this function, the propiate IP info should be filled in ip_prefix
# and nodes.
function resolve_args()
{
    local ipprefix=$ip_prefix
    local ipcluster=$ip_cluster_prefix
    local ipstart=0
    local ipend=0
    local cnt=0
    local i=0
    local j=0

    # process prefix, make sure it is in the format of x.x.x.
    if [[ ! $ipprefix =~ \.$ ]];then
	ip_prefix=${ip_prefix}.
    fi

    if [[ ! $ipcluster =~ \.$ ]];then
	ip_cluster_prefix=${ip_cluster_prefix}.
    fi

    if [[ `echo $ip_range | grep "-"` != "" ]]; then
	ipstart=`echo $ip_range | cut -d- -f1`
	ipend=`echo $ip_range | cut -d- -f2`
	cnt=`expr $ipend - $ipstart + 1`
	j=0
	for i in `seq $ipstart $ipend`
	do
	    nodes[$j]=$i
	    ((j+=1))
	done
    elif [[ `echo $ip_range | grep ","` != "" ]]; then
	ips=`echo $ip_range | sed "s/,/ /g"`
	for i in `echo $ips`
	do
	    nodes[$j]=$i
	    ((j+=1))
	done
    fi
    i=0
}

function check_connection()
{
    local ipsuffix_arr=(${nodes[@]})
    local ipprefix=$ip_prefix
    local len=${#nodes[@]}
    local i=1
    local -a tmparr
    for ip in ${ipsuffix_arr[@]}
    do
	echo "${ipprefix}${ip}"
	tmparr=${nodes[@]:$i:$len}
	if [[ $tmparr != "" ]]; then
		for destip in ${tmparr[@]}
		do
			timeout $timeout_val ssh root@${ipprefix}${ip} "ping ${ipprefix}${destip} -c $ping_count"
		done
	fi
	((i+=1))
    done
}

function check_perf()
{
	local ipsuffix_arr=(${nodes[@]})
	local ipprefix=$ip_cluster_prefix
	local len=${#nodes[@]}
	local i=1
	local -a tmparr
	logname=iperf.log
	for ip in ${ipsuffix_arr[@]}
	do
		echo "=========================================================" >> $logname
		echo "server-$ip" >> $logname
		echo "=========================================================" >> $logname
		start_iperfserver "${ip_prefix}${ip}"
		for destip in ${ipsuffix_arr[@]}
		do
			if [[ $destip != $ip ]];then
			timeout $timeout_val ssh root@${ip_prefix}${destip} "iperf -c ${ipprefix}${ip} -i 1 -t 10" >> $logname
			fi
		done
		stop_iperfserver "${ip_prefix}${ip}"
	done
}

resolve_args
#print_array ${nodes[@]}
#check_connection
check_perf
