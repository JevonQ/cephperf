#!/bin/sh

HOST1=ceph01
HOST2=ceph02
HOST3=ceph03
CLUSTER=ceph
CLUSTERIP=192.168.0

if [[ `which ceph-deploy` != 0 ]]; then
        easy_install ceph-deploy
fi

ceph-deploy repo --repo-url http://mirrors.ustc.edu.cn/ceph/rpm-jewel/el7/x86_64/ $CLUSTER $HOST1 $HOST2 $HOST3

function install_ceph()
{
        for host in $HOST1 $HOST2 $HOST3
        do
                ssh root@$host "yum install ceph -y"
        done
}

function create_cluster()
{
        ceph-deploy --cluster ${CLUSTER} new --public-network ${HOSTIP}.0/24 --cluster-network ${HOSTIP}.0/24 ${HOST1} ${HOST2} ${HOST3}
        ceph-deploy --cluster ceph mon create ${HOST1} ${HOST2} ${HOST3}
        ceph-deploy --cluster ceph gatherkeys ${HOST1} ${HOST2} ${HOST3}
        ceph-deploy --cluster ceph osd prepare --fs-type xfs ${HOST1}:/dev/vdb ${HOST2}:/dev/vdb ${HOST3}:/dev/vdb
}

case $1 in
        create)
                create_cluster
                ;;
        destroy)
                destroy_cluster
                ;;
        esac
