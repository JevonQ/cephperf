#!/bin/sh

REPOURL=http://mirrors.ustc.edu.cn/ceph/rpm-jewel/el7/x86_64/
HOSTNAME=`hostname`
CLUSTERNAME=ceph
HOSTIP=`ip a | grep "\<inet\>" | grep -v "127.0.0.1" | awk '{print $2}' | cut -d / -f 1 | cut -d . -f 1-3`

if [[ `which ceph-deploy` != 0 ]]; then
	easy_install ceph-deploy
fi

# config ceph repo for centos 7.1 only
ceph-deploy repo --repo-url $REPOURL $CLUSTERNAME $HOSTAME

function create_cluster()
{
	yum install ceph -y
	ceph-deploy --cluster ${CLUSTERNAME} new --public-network ${HOSTIP}.0/24 --cluster-network ${HOSTIP}.0/24 ${HOSTNAME}
	ceph-deploy --cluster ${CLUSTERNAME} mon create ${HOSTNAME}
	ceph-deploy --cluster ${CLUSTERNAME} gatherkeys ${HOSTNAME}
}

function destroy_cluster()
{
	rpm -qa|grep ceph|xargs yum erase
	mount|grep ceph|awk '{print $3}'|while read mountpoint;
	do
		umount $mountpoint
	done
	rm -rf /var/lib/ceph/*
}

case $1 in
	create)
		create_cluster
		;;
	destroy)
		destroy_cluster
		;;
	esac
